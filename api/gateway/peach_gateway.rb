require './api/utils/rest_util'
require './api/services/config_service'
require 'json'

class PeachGateway
  def initialize(rest_util = RestUtil, config_service = ConfigurationService)
    @rest_util = rest_util.new
    @config = config_service.new.get_config
  end

  def send_checkout_request(payment_type, amount, currency)
    # see http://support.peachpayments.com/hc/en-us/articles/205160077-Authentication-IDs-for-REST-API

    # authentication.userId = USER LOGIN
    # authentication.password = USER PWD
    # authentication.entityId = CHANNEL ID / 3DS CHANNEL ID

    uri = "#{@config[:peachpayments_api_uri]}/checkouts"
    user_id = @config[:peachpayments_api_user_id]
    password = @config[:peachpayments_api_password]
    entity_id = @config[:peachpayments_api_entity_id]

    payload = {
        'authentication.userId' => user_id,
        'authentication.password' => password,
        'authentication.entityId' => entity_id,
        'paymentType' => payment_type,
        'amount' => amount,
        'currency' => currency
    }

    @rest_util.execute_form_post(uri, nil, payload)
  end
end