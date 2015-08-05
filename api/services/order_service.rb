require './api/errors/api_error'
require './api/constants/error_constants'
require './api/services/config_service'
require './api/repositories/order_repository'
require './api/gateways/payment_gateway'
require './api/services/log_service'
require './api/models/transaction'
require './api/models/order'

class OrderService
  include LogService
  include ErrorConstants::ApiErrors

  def initialize(config_service = ConfigurationService, order_repository = OrderRepository, payment_gateway = PaymentGateway)
    @config = config_service.new.get_config
    @order_repository = order_repository.new
    @payment_gateway = payment_gateway.new
  end

  def create_order(type, amount, currency, products)
    case type
      when 'vin_purchase'
        checkout_id = nil
        response = @payment_gateway.send_checkout_request('DB', amount, currency)

        if response.response_code == 200
          json = JSON.parse(response.response_body, :symbolize_names => true)
          result_code = json[:result][:code]
        else
          raise ApiError, PAYMENT_CHECKOUT_REQUEST_FAIL
        end

        @config[:payment_success_codes].each do |code|
          checkout_id = json[:id] if result_code.to_s == code.to_s
        end

        raise ApiError, PAYMENT_CHECKOUT_ID_FAIL if checkout_id.to_s == ''

        if checkout_id != nil
          @order_repository.create_vin_purchase_order(checkout_id, amount, currency, products)
          return checkout_id

          # NOTE: polling for checkout status occurs in the QueueProcessorService
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
          return true
        end
      end

      return false
    rescue Exception => e
      raise ApiError, e.message
    end
  end
end