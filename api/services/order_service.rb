require './api/errors/api_error'
require './api/constants/error_constants'
require './api/services/config_service'
require './api/services/queue_service'
require './api/repositories/order_repository'
require './api/gateways/payment_gateway'
# require './api/services/log_service'
require './api/models/transaction'
require './api/models/order'

class OrderService
  # include LogService
  include ErrorConstants::ApiErrors

  def initialize(config_service = ConfigurationService, order_repository = OrderRepository,
                 queue_service = QueueService, payment_gateway = PaymentGateway)
    @config = config_service.new.get_config
    @queue_service = queue_service.new
    @order_repository = order_repository.new
    @payment_gateway = payment_gateway.new
  end

  def create_order(data)
    type = data[:type]

    case type
      when 'vin_purchase'
        quantity = data[:products][0][:quantity]
        product_id = data[:products][0][:id]
        currency = data[:currency]

        # we need to do a product lookup to get the details


        checkout_id = nil

        # a vin purchase should only have 1 product - we need to do a product lookup to get
        # line_item = products[:]

        response = @payment_gateway.send_checkout_request('DB', amount, currency)

        if response.response_code == 200

          json = JSON.parse(response.response_body, :symbolize_names => true)
          result_code = json[:result][:code]

          @config[:payment_pending_codes].each do |code|
            checkout_id = json[:id] if result_code.to_s == code.to_s
          end

          raise ApiError, PAYMENT_CHECKOUT_ID_FAIL if checkout_id.to_s == ''

          order = @order_repository.create_vin_purchase_order(checkout_id, amount, currency, products)

          # Add checkout_id to queue - polling for checkout status occurs in the QueueProcessorService
          @queue_service.add_item_to_queue order.id, checkout_id

          return checkout_id
        else
          raise ApiError, PAYMENT_CHECKOUT_REQUEST_FAIL
        end

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