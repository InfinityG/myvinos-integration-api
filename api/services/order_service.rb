require './api/errors/api_error'
require './api/constants/error_constants'
require './api/services/config_service'
require './api/services/queue_service'
require './api/services/product_service'
require './api/repositories/order_repository'
require './api/gateways/payment_gateway'
# require './api/services/log_service'
require './api/models/transaction'
require './api/models/order'

class OrderService
  # include LogService
  include ErrorConstants::ApiErrors

  def self.build(config_service = ConfigurationService, order_repository = OrderRepository,
            queue_service = QueueService, product_service = ProductService, payment_gateway = PaymentGateway)
    new(config_service.new, order_repository.new, queue_service.new, product_service.new, payment_gateway.new)
  end

  def initialize(config_service, order_repository, queue_service, product_service, payment_gateway)
    @config = config_service.get_config
    @queue_service = queue_service
    @product_service = product_service
    @order_repository = order_repository
    @payment_gateway = payment_gateway
  end

  def create_order(user, data)
    type = data[:type]

    case type
      when 'vin_purchase'

        return get_checkout_id(data, user)

      when 'vin_redemption'
        # VIN REDEMPTION
        # 1. check user balance
        # 2. check product availability (?)
        # 3. create order on WooCommerce
        # 4. create order (local) and set external_order_id
        # 5. create transaction record
        # 6. update order record with transaction
        # 7. UPDATE BALANCE (DEBIT VIN)
      else
        raise ApiError, UNRECOGNISED_PAYMENT_TYPE
    end

    # user_id = @current_user.id
    # log(user_id, 'Order', order.id, 'create_order', "Create #{type} order")

  end

  def get_checkout_id(data, user)
    checkout_id = nil
    amount = 0

    # look up the products - in this case they should be one or more VINOs bundles, which should all have the same currency (ZAR)
    products = []

    data[:products].each do |item|
      product = @product_service.get_product(item[:product_id])
      amount += (product.price.to_i * item[:quantity].to_i)
      products << product
    end

    # send the checkout request
    response = @payment_gateway.send_checkout_request('DB', amount, @config[:default_fiat_currency])

    if response.response_code == 200

      json = JSON.parse(response.response_body, :symbolize_names => true)
      result_code = json[:result][:code]

      # check the response codes
      @config[:payment_pending_codes].each do |code|
        checkout_id = json[:id] if result_code.to_s == code.to_s
      end

      raise ApiError, PAYMENT_CHECKOUT_ID_FAIL if checkout_id.to_s == ''

      order = @order_repository.create_vin_purchase_order(user.id.to_s, checkout_id, amount, @config[:default_fiat_currency], products)

      # Add checkout_id to queue - polling for checkout status occurs in the QueueProcessorService
      @queue_service.add_item_to_queue order.id, checkout_id

      checkout_id
    else
      raise ApiError, PAYMENT_CHECKOUT_REQUEST_FAIL
    end
  end

  def update_order_transaction(order_id, external_transaction_id, status)
    @order_repository.update_order_transaction_status order_id, external_transaction_id, status
  end

  def get_checkout_status(checkout_id)
    # FOR POSSIBLE RESPONSE CODES:
    # http://support.peachpayments.com/hc/en-us/articles/205282107-Determine-Transaction-Status-from-Result-Code
    #http://support.peachpayments.com/hc/en-us/article_attachments/201425397/resultCodes.properties

    begin
      response = @payment_gateway.get_checkout_status(checkout_id)
      json = JSON.parse(response.response_body, :symbolize_names => true)
      result_code = json[:result][:code]

      @config[:payment_success_codes].each do |code|
        if result_code.to_s == code.to_s
          return {:success => true, :transaction_id => json[:id]}
        end
      end

      return {:success => false}
    rescue Exception => e
      raise ApiError, e.message
    end
  end
end