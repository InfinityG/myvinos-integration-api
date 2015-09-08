require './api/utils/rest_util'
require './api/services/config_service'
require './api/constants/error_constants'
require './api/errors/api_error'
require 'json'

class PaymentGateway
  include ErrorConstants::ApiErrors

  def initialize(rest_util = RestUtil, config_service = ConfigurationService)
    @rest_util = rest_util.new
    @config = config_service.new.get_config
  end

  def send_checkout_request(payment_type, amount, currency)
    # see http://support.peachpayments.com/hc/en-us/articles/205160077-Authentication-IDs-for-REST-API

    # authentication.userId = USER LOGIN
    # authentication.password = USER PWD
    # authentication.entityId = CHANNEL ID / 3DS CHANNEL ID

    uri = "#{@config[:payment_api_uri]}/checkouts"
    user_id = @config[:payment_api_user_id]
    password = @config[:payment_api_password]
    entity_id = @config[:payment_api_entity_id]

    payload = {
        'authentication.userId' => user_id,
        'authentication.password' => password,
        'authentication.entityId' => entity_id,
        'paymentType' => payment_type,
        'amount' => amount,
        'currency' => currency
    }

    # SAMPLE RESPONSE:
    # {
    #     "result": {
    #         "code": "000.200.100",
    #         "description": "successfully created checkout"
    #     },
    #     "buildNumber": "20150731-144831.r187089.opp-tags-20150806_lr",
    #     "timestamp": "2015-08-05 11:57:38+0000",
    #     "ndc": "942ABEAAD1F6C7C3E5A72E4FA4FB66D3.sbg-vm-tx02",
    #     "id": "942ABEAAD1F6C7C3E5A72E4FA4FB66D3.sbg-vm-tx02"
    # }

    begin
      response = @rest_util.execute_form_post(uri, nil, payload)

      if response.response_code != 200
        message = "#{THIRD_PARTY_PAYMENT_CHECKOUT_ID_REQUEST_FAIL} | Response code: #{response.response_code}"
        LOGGER.error message
        raise ApiError, message
      end

      return response
    rescue RestClient::Exception => e
      message = "#{THIRD_PARTY_PAYMENT_CHECKOUT_ID_REQUEST_FAIL}: #{e.http_code} | #{e.http_body}"
      LOGGER.error message
      raise ApiError, message
    end
  end

  def get_checkout_status(checkout_id)

    user_id = @config[:payment_api_user_id]
    password = @config[:payment_api_password]
    entity_id = @config[:payment_api_entity_id]
    uri = "#{@config[:payment_api_uri]}/checkouts/#{checkout_id}/payment" +
        "?authentication.userId=#{user_id}&authentication.password=#{password}&authentication.entityId=#{entity_id}"

    # SAMPLE RESPONSE (GOOD):
    # {
    #     "id":"8a82944a4efab241014efd9a2a2215c3",
    #     "paymentType":"DB",
    #     "paymentBrand":"AMEX",
    #     "amount":"50.99",
    #     "currency":"EUR",
    #     "descriptor":"2469.8444.2530 Non3D_Channel",
    #     "result":{
    #         "code":"000.100.110",
    #         "description":"Request successfully processed in 'Merchant in Integrator Test Mode'"
    #     },
    #     "card":{
    #         "bin":"311111",
    #         "last4Digits":"1117",
    #         "holder":"Test",
    #         "expiryMonth":"12",
    #         "expiryYear":"2015"
    #     },
    #     "buildNumber":"20150731-144831.r187089.opp-tags-20150806_lr",
    #     "timestamp":"2015-08-05 11:23:35+0000",
    #     "ndc":"5BCF63BF4AFABEFA03165843A0EF7A12.sbg-vm-tx02"
    # }

    # SAMPLE RESPONSE (BAD)
    # {
    #     "result":{
    #         "code":"200.300.404",
    #         "description":"invalid or missing parameter - (opp) session does not exist"
    #     },
    #     "buildNumber":"20150731-144831.r187089.opp-tags-20150806_lr",
    #     "timestamp":"2015-08-05 11:25:35+0000",
    #     "ndc":"5f5c0f6f4bd444a8b6ac094d4bf6d42e"
    # }

    begin
      response = @rest_util.execute_get(uri, nil)
      if response.response_code != 200
        message = "#{THIRD_PARTY_PAYMENT_CHECKOUT_STATUS_REQUEST_FAIL} | Response code: #{response.response_code}"
        LOGGER.error message
        raise ApiError, message
      end
      return response
    rescue RestClient::Exception => e
      message = "#{THIRD_PARTY_PAYMENT_CHECKOUT_STATUS_REQUEST_FAIL}: #{e.http_code} | #{e.http_body}"
      LOGGER.error message
      raise ApiError, message
    end
  end
end