require './api/errors/api_error'
require './api/constants/error_constants'
require './api/constants/api_constants'
require './api/services/config_service'
require './api/services/queue_service'
require './api/services/product_service'
require './api/services/user_service'
require './api/services/delivery_service'
require './api/gateways/product_gateway'
require './api/repositories/order_repository'
require './api/repositories/card_repository'
require './api/gateways/payment_gateway'
require './api/utils/time_util'
# require './api/services/log_service'
require './api/models/transaction'
require './api/models/order'

class OrderService
  # include LogService
  include ErrorConstants::ApiErrors
  include ApiConstants
  include ApiConstants::MembershipConstants
  include TimeUtil

  def self.build(config_service = ConfigurationService,
      order_repository = OrderRepository,
      queue_service = QueueService,
      product_service = ProductService,
      product_gateway = ProductGateway,
      payment_gateway = PaymentGateway,
      user_service = UserService,
      card_repository = CardRepository,
      delivery_service = DeliveryService)

    new(config_service.new, order_repository.new, queue_service.new, product_service.new, product_gateway.new,
        payment_gateway.new, user_service.new, delivery_service.new, card_repository.new)
  end

  def initialize(config_service, order_repository, queue_service, product_service, product_gateway, payment_gateway,
                 user_service, delivery_service, card_repository)
    @config = config_service.get_config
    @queue_service = queue_service
    @product_service = product_service
    @product_gateway = product_gateway
    @order_repository = order_repository
    @payment_gateway = payment_gateway
    @user_service = user_service
    @delivery_service = delivery_service
    @card_repository = card_repository
  end

  def get_orders(user)
    @order_repository.get_non_abandoned_orders(user.id.to_s)
  end

  def create_order(user, data)
    type = data[:type]

    case type
      when VIN_PURCHASE_TYPE
        return create_vin_purchase_order(data, user)
      when MEMBERSHIP_PURCHASE_TYPE
        return create_mem_purchase_order(data, user)
      when VIN_REDEMPTION_TYPE
        return create_vin_redemption_order(data, user)
      else
        raise ApiError, UNRECOGNISED_PAYMENT_TYPE
    end
  end

  ###################
  # VINOS purchases
  ###################

  def create_vin_purchase_order(data, user)
    products = []

    amount = calculate_vin_purchase_amount(data, products)
    converted_amount = RateUtil.convert_vin_to_fiat amount

    stored_cards = @card_repository.get_cards_for_user user.id.to_s
    checkout_id = create_checkout_id(stored_cards, converted_amount, true)

    order = @order_repository.create_vin_purchase_order(user.id.to_s, checkout_id, amount,
                                                        @config[:default_fiat_currency], products)

    @queue_service.add_item_to_queue order.id, checkout_id

    {
        :id => order.id.to_s,
        :status => order.transaction.status,
        :checkout_id => checkout_id,
        :checkout_uri => @config[:payment_widget_uri]
    }

  end

  def create_mem_purchase_order(data, user)
    products = []

    membership_type = get_membership_type data
    amount = calculate_vin_purchase_amount(data, products)

    # check if the user's current balance is within the limit for the membership
    payment_required = user.balance < amount
    # payment_required = true

    if payment_required
      converted_amount = RateUtil.convert_vin_to_fiat amount
      stored_cards = @card_repository.get_cards_for_user user.id.to_s

      checkout_id = create_checkout_id(stored_cards, converted_amount, true)
      checkout_uri = @config[:payment_widget_uri]

      order = @order_repository.create_mem_purchase_order(user.id.to_s, checkout_id, nil, amount,
                                                          @config[:default_fiat_currency], products,
                                                          PAYMENT_STATUS_PENDING, USER_INITIATED_PAYMENT_MEMO)

      # add the item to the queue - when this is processed then the membership will be updated
      @queue_service.add_item_to_queue order.id, checkout_id

      ################################################################################
      # ABSTRACT THE FOLLOWING INTO THE VINOS_REDEMPTION ORDER PROCESS
      ################################################################################
      # if there are no stored cards, then initiate a checkout id request
      # if stored_cards.length == 0
      #
      # else
      #   # if there is a stored card, then we want to use this to create an automatic top-up (recurring payment)
      #   default_card = stored_cards.find do |stored_card|
      #     stored_card.default
      #   end
      #
      #   # send the recurring payment
      #   payment_id = create_recurring_payment_id default_card, converted_amount
      #
      #   order = @order_repository.create_mem_purchase_order(user.id.to_s, nil, payment_id, amount,
      #                                                       @config[:default_fiat_currency], products,
      #                                                       PAYMENT_STATUS_COMPLETE, RECURRING_PAYMENT_MEMO)
      # end

    else
      # no payment required - create the order with the transaction
      checkout_id = nil
      checkout_uri = nil
      order = @order_repository.create_mem_purchase_order(user.id.to_s, nil, nil, amount,
                                                          @config[:default_fiat_currency], products,
                                                          PAYMENT_STATUS_COMPLETE, NO_PAYMENT_REQUIRED_MEMO)

      @user_service.update_membership user.id.to_s, membership_type
    end

    {
        :id => order.id.to_s,
        :status => order.transaction.status,
        :checkout_id => checkout_id,
        :checkout_uri => checkout_uri
    }

  end

  def get_membership_type(data)
    raise ApiError, MEMBERSHIP_QUANTITY_ERROR if data[:products].length > 1

    product_id = data[:products][0][:product_id]
    cached_product = @product_service.get_product product_id

    membership_type = MEMBERSHIP_TYPES.find do |type|
      return type if cached_product.name.to_s.downcase.include? type
    end

    raise ApiError, MEMBERSHIP_TYPE_NOT_FOUND if membership_type == nil

    membership_type
  end

  def calculate_vin_purchase_amount(data, products)
    # look up the products - in this case they should be one or more VINOs bundles, which should all have the same currency (ZAR)
    amount = 0

    data[:products].each do |item|
      product = @product_service.get_product(item[:product_id])
      raise ApiError, INVALID_PRODUCT if product == nil

      if product.product_type != TOP_UP_PRODUCT_TYPE && product.product_type != MEMBERSHIP_PRODUCT_TYPE
        raise ApiError, INVALID_TOP_UP_OR_MEMBERSHIP_PRODUCT
      end

      amount += (product.price.to_i * item[:quantity].to_i)

      products << {:product_id => product.product_id,
                   :quantity => item[:quantity].to_i,
                   :name => product.name,
                   :description => product.description,
                   :price => product.price}
    end

    amount
  end

  def update_order_transaction(order_id, external_transaction_id, status)
    @order_repository.update_order_transaction_status order_id, external_transaction_id, status
  end

  def get_checkout_status(checkout_id, creation_date)

    # check if the expiry period has been reached
    if (Time.now.to_i - creation_date.to_i) > @config[:purchase_order_timeout].to_i
      return {:status => 'abandoned'}
    end
    # FOR POSSIBLE RESPONSE CODES:
    # http://support.peachpayments.com/hc/en-us/articles/205282107-Determine-Transaction-Status-from-Result-Code
    #http://support.peachpayments.com/hc/en-us/article_attachments/201425397/resultCodes.properties

    checkout_response = send_checkout_status_request checkout_id
    result_code = checkout_response[:result][:code]
    result_description = checkout_response[:result][:description]

    if @config[:payment_pending_codes].include? result_code.to_s
      return {:status => 'pending'}
    end

    if @config[:payment_success_codes].include? result_code.to_s
      transaction_id = checkout_response[:id]

      # these fields will be returned if createRegistration=true
      registration_id = checkout_response[:registrationId]
      card = checkout_response[:card]

      return {
          :status => 'success',
          :transaction_id => transaction_id,
          :registration_id => registration_id,
          :card => card
      }
    end

    {:status => 'failure', :description => result_description}
  end

  ###################
  # VINOS redemption
  ###################

  def create_vin_redemption_order(data, user)

    raise ApiError, OUTSIDE_DELIVERY_HOURS_ERROR unless confirm_within_delivery_hours

    parsed_products = parse_products(data, user.balance)
    local_order = create_local_order(user, parsed_products, data[:location], data[:notes])

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

  def confirm_within_delivery_hours

    if @config[:delivery_hours_active]
      current_hour = TimeUtil.get_current_hour_in_zone @config[:time_zone]
      return (@config[:delivery_hours_start] < current_hour) && (@config[:delivery_hours_end] > current_hour)
    end

    true
  end

  def create_local_order(user, parsed_products, location, notes)
    @order_repository.create_vin_redemption_order(user,
                                                  parsed_products[:total],
                                                  @config[:default_crypto_currency],
                                                  parsed_products[:order_products],
                                                  location, notes)
  end

  def create_third_party_order(local_order, user, parsed_products)
    begin
      address = "#{local_order.delivery.address} (#{local_order.delivery.coordinates})"
      third_party_order = send_order_create_request(user, address, parsed_products)
      local_order.external_order_id = third_party_order[:order][:id]
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
      local_order.delivery.time_estimate = (delivery[:time_estimate].to_i/60).to_s
      local_order.delivery.distance_estimate = delivery[:distance_estimate]
    rescue ApiError
      local_order.status = 'third party delivery creation failed'
      local_order.delivery.status = 'failed'
    end
  end

  def update_third_party_order_status(local_order)
    # update the order status on the 3rd party
    begin
      send_order_update_request local_order.external_order_id, 'processing'
      local_order.status = 'complete'
      local_order.transaction.status = 'complete'
    rescue ApiError
      # @order_repository.update_order_status local_order.id, 'third party order update failed'
      local_order.status = 'third party order update failed'
      local_order.transaction.status = 'complete'
    end
  end

  def update_balance(user, parsed_products)
    @user_service.update_balance_for_redemption user.id.to_s, -parsed_products[:total]
  end

  #########################
  # VINOS BONUS ORDERS
  #########################
  def create_vinos_bonus_order(data, user)
    # TODO
  end

  ###########
  # HELPERS
  ###########

  def create_checkout_id(stored_cards, amount, init_recurring)
    checkout_id = nil
    checkout_response = send_checkout_id_request stored_cards, amount, init_recurring
    result_code = checkout_response[:result][:code]

    # check the response codes against the success code list
    checkout_id = checkout_response[:id] if @config[:payment_pending_codes].include? result_code.to_s

    checkout_id
    end

  def create_recurring_payment_id(default_card, amount)
    recurring_payment_id = nil
    payment_response = send_recurring_payment_request default_card, amount
    result_code = payment_response[:result][:code]

    # check the response codes against the success code list
    recurring_payment_id = payment_response[:id] if @config[:payment_success_codes].include? result_code.to_s

    recurring_payment_id
  end

  def parse_products(data, current_balance)
    running_total = 0
    order_products_arr = []

    data[:products].each do |product|
      id = product[:product_id]
      quantity = product[:quantity].to_i

      check_availability(id, quantity)

      cached_product = @product_service.get_product id
      raise ApiError, INVALID_PRODUCT if cached_product == nil

      # HOTFIX on 17/11/2015 (price now being multiplied by quantity):
      price = (cached_product.price.to_i * quantity)
      running_total += price

      raise ApiError, INSUFFICIENT_VINOS if running_total > current_balance

      order_products_arr << {:product_id => id,
                             :quantity => quantity,
                             :name => cached_product.name,
                             :description => cached_product.description,
                             :price => cached_product.price}
    end

    # delivery charges
    if @config[:minimum_delivery_active] && running_total < @config[:minimum_delivery_amount]

      delivery_product = @product_service.get_delivery_product
      order_products_arr << {:product_id => delivery_product.product_id,
                             :quantity => 1,
                             :name => delivery_product.name,
                             :description => delivery_product.description,
                             :price => delivery_product.price}

      running_total += delivery_product.price.to_i
      raise ApiError, INSUFFICIENT_VINOS if running_total > current_balance
    end

    {:order_products => order_products_arr, :total => running_total}
  end

  def check_availability(id, quantity)
    # check product count on 3rd party (note this is NOT mapped)
    live_product = @product_service.get_live_product id
    raise ApiError, PRODUCT_NOT_IN_STOCK if live_product == nil

    live_quantity = live_product[:product][:stock_quantity].to_i
    raise ApiError, "#{INSUFFICIENT_STOCK_QUANTITY} for #{live_product[:product][:title]}" if live_quantity < quantity
  end

  def send_checkout_id_request(stored_cards, amount, init_recurring)
    response = @payment_gateway.send_checkout_request(stored_cards, 'DB', amount, @config[:default_fiat_currency], init_recurring)
    JSON.parse(response.response_body, :symbolize_names => true)
  end

  def send_checkout_status_request(checkout_id)
    response = @payment_gateway.get_checkout_status(checkout_id)
    JSON.parse(response.response_body, :symbolize_names => true)
  end

  def send_recurring_payment_request(card, amount)
    response = @payment_gateway.send_recurring_payment_request(card, 'DB', amount, @config[:default_fiat_currency])
    JSON.parse(response.response_body, :symbolize_names => true)
  end

  def send_order_create_request(user, address, products_arr)
    order_response = @product_gateway.create_order user, address, products_arr
    JSON.parse(order_response.response_body, :symbolize_names => true)
  end

  def send_order_update_request(third_party_order_id, status)
    order_response = @product_gateway.update_order_status third_party_order_id, status
    JSON.parse(order_response.response_body, :symbolize_names => true)
  end

  def send_delivery_request(user, order)
    @delivery_service.send_delivery_request user, order
  end
end