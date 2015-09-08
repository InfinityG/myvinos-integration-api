require './api/utils/rest_util'
require './api/utils/key_provider'
require './api/services/config_service'
require './api/constants/error_constants'
require './api/errors/api_error'
require 'json'

class DeliveryGateway
  include ErrorConstants::ApiErrors

  def initialize(rest_util = RestUtil, key_provider = KeyProvider, config_service = ConfigurationService)
    @rest_util = rest_util.new
    @config = config_service.new.get_config
    @key_provider = key_provider.new
  end

  def send_delivery_request(user, order)
    data = {
        :pickup_address => @config[:pickup_address],
        :pickup_contact_name => @config[:pickup_contact_name],
        :pickup_contact_phone => @config[:pickup_contact_phone],
        :pickup_coordinates => @config[:pickup_coords],
        :dropoff_address => order.delivery.address,
        :dropoff_contact_name => "#{user[:first_name]} #{user[:last_name]}",
        :dropoff_contact_phone => order.delivery.phone,
        :dropoff_coordinates => order.delivery.coordinates,
        :customer_identifier => user[:username]
    }

    uri= "#{@config[:delivery_api_uri]}/deliveries"
    auth_header = @key_provider.get_delivery_api_auth

    begin
      response = @rest_util.execute_post(uri, auth_header, data.to_json)
      if response.response_code != 200
        message = "#{THIRD_PARTY_DELIVERY_REQUEST_ERROR} | Response code: #{response.response_code}"
        LOGGER.error message
        raise ApiError, message
      end
      return response
    rescue RestClient::Exception => e
      message = "#{THIRD_PARTY_DELIVERY_REQUEST_ERROR}: #{e.http_code} | #{e.http_body}"
      LOGGER.error message
      raise ApiError, message
    end
  end
end