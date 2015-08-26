require './api/utils/rest_util'
require './api/utils/key_provider'
require './api/services/config_service'
require './api/constants/error_constants'
require './api/errors/api_error'
require 'json'

class ProductGateway

  include ErrorConstants::ApiErrors

  def initialize(rest_util = RestUtil, key_provider = KeyProvider, config_service = ConfigurationService)
    @rest_util = rest_util.new
    @config = config_service.new.get_config
    @key_provider = key_provider.new
  end

  def get_all_products
    uri= "#{@config[:product_api_uri]}/products?filter[limit]=1000"
    auth_header = @key_provider.get_product_api_auth_key

    begin
      response = @rest_util.execute_get(uri, auth_header)
      raise ApiError, "#{THIRD_PARTY_USER_CREATION_ERROR} | Response code: #{response.response_code}" if response.response_code != 200
      return response
    rescue RestClient::Exception => e
      raise ApiError, "#{THIRD_PARTY_PRODUCT_REQUEST_ERROR}: #{e.http_code} | #{e.http_body}"
    end
  end

  def get_product(product_id)
    uri= "#{@config[:product_api_uri]}/products/#{product_id}"
    auth_header = @key_provider.get_product_api_auth_key

    @rest_util.execute_get(uri, auth_header)

    begin
      response = @rest_util.execute_get(uri, auth_header)
      raise ApiError, "#{THIRD_PARTY_USER_CREATION_ERROR} | Response code: #{response.response_code}" if response.response_code != 200
      return response
    rescue RestClient::Exception => e
      raise ApiError, "#{THIRD_PARTY_PRODUCT_REQUEST_ERROR}: #{e.http_code} | #{e.http_body}"
    end
  end

  def get_user(email)
    uri= "#{@config[:product_api_uri]}/customers/email/#{email}"
    auth_header = @key_provider.get_product_api_auth_key

    begin
      response = @rest_util.execute_get(uri, auth_header)
      raise ApiError, "#{THIRD_PARTY_USER_CREATION_ERROR} | Response code: #{response.response_code}" if response.response_code != 200
      return response
    rescue RestClient::Exception => e
      raise ApiError, "#{THIRD_PARTY_USER_REQUEST_ERROR}: #{e.http_code} | #{e.http_body}"
    end
  end

  def create_user(username, email, first_name, last_name)
    data = {
        :customer => {
            :email => email,
            :first_name => first_name,
            :last_name => last_name,
            :username => username
        }
    }

    uri= "#{@config[:product_api_uri]}/customers"
    auth_header = @key_provider.get_product_api_auth_key

    begin
      response =  @rest_util.execute_post(uri, auth_header, data.to_json)
      raise ApiError, "#{THIRD_PARTY_USER_CREATION_ERROR} | Response code: #{response.response_code}" if response.response_code != 200
      return response
    rescue RestClient::Exception => e
      raise ApiError, "#{THIRD_PARTY_USER_CREATION_ERROR}: #{e.http_code} | #{e.http_body}"
    end
  end

  def create_order(user, products)

    data = {
        :order => {
            :payment_details => {
                :method_id => 'account_funds',
                :method_title => 'VINOS',
                :paid => true
            },
            :billing_address => nil,
            :shipping_address => nil,
            :customer_id => user.id.to_i,
            :line_items => products,
            :shipping_lines => [
                {
                    :method_id => 'distance_rate',
                    :method_title => 'On-Demand Mobile Wine Steward',
                    :total => 0
                }
            ]
        }
    }

    uri= "#{@config[:product_api_uri]}/orders"
    auth_header = @key_provider.get_product_api_auth_key

    begin
      return @rest_util.execute_post(uri, auth_header, data.to_json)
    rescue RestClient::Exception => e
      raise ApiError, "#{THIRD_PARTY_ORDER_CREATION_ERROR}: #{e.http_code} | #{e.http_body}"
    end

  end
end