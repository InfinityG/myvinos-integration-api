require './api/errors/api_error'
require './api/constants/error_constants'
require './api/services/config_service'
require './api/services/queue_service'
require './api/services/product_service'
require './api/services/user_service'
require './api/services/delivery_service'
require './api/gateways/product_gateway'
require './api/repositories/order_repository'
require './api/gateways/payment_gateway'
# require './api/services/log_service'
require './api/models/transaction'
require './api/models/order'

class OrderService
  # include LogService
  include ErrorConstants::ApiErrors

  def self.build(config_service = ConfigurationService,
      order_repository = OrderRepository,
      queue_service = QueueService,
      product_service = ProductService,
      product_gateway = ProductGateway,
      payment_gateway = PaymentGateway,
      user_service = UserService,
      delivery_service = DeliveryService)

    new(config_service.new, order_repository.new, queue_service.new, product_service.new, product_gateway.new,
        payment_gateway.new, user_service.new, delivery_service.new)
  end

  def initialize(config_service, order_repository, queue_service, product_service, product_gateway, payment_gateway,
                 user_service, delivery_service)
    @config = config_service.get_config
    @queue_service = queue_service
    @product_service = product_service
    @product_gateway = product_gateway
    @order_repository = order_repository
    @payment_gateway = payment_gateway
    @user_service = user_service
    @delivery_service = delivery_service
  end

  def get_orders(user)
    @order_repository.get_orders(user.id.to_s)
  end

  def create_order(user, data)
    type = data[:type]

    case type
      when 'vin_purchase'
        return create_vin_purchase_order(data, user)
      when 'vin_redemption'
        return create_vin_redemption_order(data, user)
      else
        raise ApiError, UNRECOGNISED_PAYMENT_TYPE
    end
  end

  ###################
  # VINOS purchases
  ###################

  def create_vin_purchase_order(data, user)
    amount = 0
    products = []

    # look up the products - in this case they should be one or more VINOs bundles, which should all have the same currency (ZAR)
    data[:products].each do |item|
      product = @product_service.get_product(item[:product_id])
      amount += (product.price.to_i * item[:quantity].to_i)
      products << product
    end

    checkout_id = create_checkout_id(amount)

    order = @order_repository.create_vin_purchase_order(user.id.to_s, checkout_id, amount,
                                                        @config[:default_fiat_currency], products)

    @queue_service.add_item_to_queue order.id, checkout_id

    {
        :id => order.id.to_s,
        :status => order.transaction.status,
        :checkout_id => checkout_id
    }

  end

  def update_order_transaction(order_id, external_transaction_id, status)
    @order_repository.update_order_transaction_status order_id, external_transaction_id, status
  end

  def get_checkout_status(checkout_id)
    # FOR POSSIBLE RESPONSE CODES:
    # http://support.peachpayments.com/hc/en-us/articles/205282107-Determine-Transaction-Status-from-Result-Code
    #http://support.peachpayments.com/hc/en-us/article_attachments/201425397/resultCodes.properties

    checkout_response = send_checkout_status_request checkout_id
    result_code = checkout_response[:result][:code]
    result_description = checkout_response[:result][:description]

    @config[:payment_success_codes].each do |code|
      return {:success => true, :transaction_id => checkout_response[:id]} if result_code.to_s == code.to_s
    end

    {:success => false, :description => result_description}
  end

  ###################
  # VINOS redemption
  ###################

  def create_vin_redemption_order(data, user)

    parsed_products = parse_products(data, user.balance)
    local_order = create_local_order(user, parsed_products, data[:location])

    # these operations all update fields on the local_order (by reference)
    create_third_party_order(local_order, user, parsed_products[:order_products])
    create_delivery(local_order, user)
    update_third_party_order_status local_order

    @order_repository.update_order local_order
    balance = update_balance user, parsed_products

    {
        :id => local_order.id.to_s,
        :status => local_order.status,
        :delivery_details => {
            :status => local_order.delivery.status,
            :distance_estimate => local_order.delivery.distance_estimate,
            :time_estimate => local_order.delivery.time_estimate
        },
        :balance => balance
    }

  end

  def create_local_order(user, parsed_products, location)
    @order_repository.create_vin_redemption_order(user.id.to_s,
                                                  parsed_products[:total],
                                                  @config[:default_crypto_currency],
                                                  parsed_products[:detailed_products],
                                                  location)
  end

  def create_third_party_order(local_order, user, parsed_products)
    begin
      third_party_order = send_order_create_request(user, parsed_products[:order_products])
      local_order.external_order_id = third_party_order[:id]
    rescue ApiError
      local_order.status = 'third party order creation failed'
      raise ApiError, THIRD_PARTY_ORDER_CREATION_ERROR
    end
  end

  def create_delivery(local_order, user)
    begin
      delivery = send_delivery_request user, local_order
      local_order.delivery.status = 'complete'
      local_order.delivery.external_id = delivery[:id]
      local_order.delivery.time_estimate = delivery[:time_estimate]
      local_order.delivery.distance_estimate = delivery[:distance_estimate]
    rescue ApiError
      local_order.status = 'third party delivery creation failed'
      local_order.delivery.status = 'failed'
    end
  end

  def update_third_party_order_status(local_order)
    # update the order status on the 3rd party
    begin
      send_order_update_request local_order.external_order_id, 'complete'
      local_order.status = 'complete'
      local_order.transaction.status = 'complete'
    rescue ApiError
      # @order_repository.update_order_status local_order.id, 'third party order update failed'
      local_order.status = 'third party order update failed'
      local_order.transaction.status = 'complete'
    end
  end

  def update_balance(user, parsed_products)
    @user_service.update_balance user.id.to_s, -parsed_products[:total]
  end

  ###########
  # HELPERS
  ###########

  def create_checkout_id(amount)
    checkout_id = nil
    checkout_response = send_checkout_id_request amount
    result_code = checkout_response[:result][:code]

    # check the response codes against the success code list
    @config[:payment_pending_codes].each do |code|
      checkout_id = checkout_response[:id] if result_code.to_s == code.to_s
    end

    checkout_id
  end

  def parse_products(data, current_balance)
    running_total = 0
    detailed_products_arr = []
    order_products_arr = []

    data[:products].each do |product|
      cached_product = @product_service.get_product product.id
      raise ApiError, INVALID_PRODUCT if cached_product == nil

      price = cached_product.price.to_i
      running_total += price
      raise ApiError, INSUFFICIENT_VINOS if running_total > current_balance

      detailed_products_arr << cached_product
      order_products_arr << {:product_id => product.id, :quantity => product.quantity}
    end

    {:detailed_products => detailed_products_arr, :order_products => order_products_arr, :total => running_total}
  end

  def send_checkout_id_request(amount)
    response = @payment_gateway.send_checkout_request('DB', amount, @config[:default_fiat_currency])
    JSON.parse(response.response_body, :symbolize_names => true)
  end

  def send_checkout_status_request(checkout_id)
    response = @payment_gateway.get_checkout_status(checkout_id)
    JSON.parse(response.response_body, :symbolize_names => true)
  end

  def send_order_create_request(user, products_arr)
    order_response = @product_gateway.create_order user, products_arr
    JSON.parse(order_response.response_body, :symbolize_names => true)
  end

  def send_order_update_request(third_party_order_id, status)
    order_response = @product_gateway.update_order_status third_party_order_id, status
    JSON.parse(order_response.response_body, :symbolize_names => true)
  end

  def send_delivery_request(user, order)
    delivery_response = @delivery_service.send_delivery_request user, order
    JSON.parse(delivery_response.response_body, :symbolize_names => true)
  end
end