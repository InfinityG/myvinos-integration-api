require './api/utils/rest_util'
require './api/utils/key_provider'
require './api/services/config_service'
require './api/services/log_service'
require './api/constants/error_constants'
require './api/errors/api_error'
require 'json'

class ProductGateway

  include ErrorConstants::ApiErrors

  def initialize(rest_util = RestUtil, key_provider = KeyProvider,
                 config_service = ConfigurationService, log_service = LogService)
    @rest_util = rest_util.new
    @config = config_service.new.get_config
    @key_provider = key_provider.new
    @log_service = log_service.new
  end

  def get_all_products
    uri= "#{@config[:product_api_uri]}/products?filter[limit]=1000"
    auth_header = @key_provider.get_product_api_auth_key

    begin
      response = @rest_util.execute_get(uri, auth_header)
      unless response.response_code.to_s.start_with?('2')
        message = "#{THIRD_PARTY_PRODUCT_REQUEST_ERROR} | Response code: #{response.response_code}"
        @log_service.log_error message
        raise ApiError, message
      end
      return response
    rescue RestClient::Exception => e
      message = "#{THIRD_PARTY_PRODUCT_REQUEST_ERROR}: #{e.http_code} | #{e.http_body}"
      @log_service.log_error message
      raise ApiError, message
    end
  end

  def get_all_categories
    uri= "#{@config[:product_api_uri]}/products/categories"
    auth_header = @key_provider.get_product_api_auth_key

    begin
      response = @rest_util.execute_get(uri, auth_header)
      unless response.response_code.to_s.start_with?('2')
        message = "#{THIRD_PARTY_CATEGORY_REQUEST_ERROR} | Response code: #{response.response_code}"
        @log_service.log_error message
        raise ApiError, message
      end
      return response
    rescue RestClient::Exception => e
      message = "#{THIRD_PARTY_CATEGORY_REQUEST_ERROR}: #{e.http_code} | #{e.http_body}"
      @log_service.log_error message
      raise ApiError, message
    end
  end

  def get_product(product_id)
    uri= "#{@config[:product_api_uri]}/products/#{product_id}"
    auth_header = @key_provider.get_product_api_auth_key

    @rest_util.execute_get(uri, auth_header)

    begin
      response = @rest_util.execute_get(uri, auth_header)
      unless response.response_code.to_s.start_with?('2')
        message = "#{THIRD_PARTY_PRODUCT_REQUEST_ERROR} | Response code: #{response.response_code}"
        @log_service.log_error message
        raise ApiError, message
      end
      return response
    rescue RestClient::Exception => e
      message = "#{THIRD_PARTY_PRODUCT_REQUEST_ERROR}: #{e.http_code} | #{e.http_body}"
      @log_service.log_error message
      raise ApiError, message
    end
  end

  def get_user(email)
    uri= "#{@config[:product_api_uri]}/customers/email/#{email}"
    auth_header = @key_provider.get_product_api_auth_key

    begin
      response = @rest_util.execute_get(uri, auth_header)
      unless response.response_code.to_s.start_with?('2')
        message = "#{THIRD_PARTY_USER_REQUEST_ERROR} | Response code: #{response.response_code}"
        @log_service.log_error message
        raise ApiError, message
      end
      return response
    rescue RestClient::Exception => e
      message = "#{THIRD_PARTY_USER_REQUEST_ERROR}: #{e.http_code} | #{e.http_body}"
      @log_service.log_error message
      raise ApiError, message
    end
  end

  def create_user(username, email, first_name, last_name, mobile_number)
    auth_header = @key_provider.get_product_api_auth_key

    begin

      uri= "#{@config[:product_api_uri]}/customers/email/#{email}"
      existing_user_result = @rest_util.execute_get(uri, auth_header)

      # if user exists, just return
      if existing_user_result.response_code == 200
        return existing_user_result
      else
        message = "#{THIRD_PARTY_USER_CREATION_ERROR} | Response code: #{existing_user_result.response_code}"
        @log_service.log_error message
        raise ApiError, message
      end

    rescue RestClient::Exception => e

      # if user not found, create new one
      if e.http_code == 404

        uri= "#{@config[:product_api_uri]}/customers"

        data = {
            :customer => {
                :email => email,
                :first_name => first_name,
                :last_name => last_name,
                :username => username,
                :billing_address => {
                    :phone => mobile_number
                }
            }
        }

        response = @rest_util.execute_post(uri, auth_header, data.to_json)
        code = response.response_code

        unless code.to_s.start_with?('2')
          message = "#{THIRD_PARTY_USER_CREATION_ERROR} | Response code: #{response.response_code}"
          @log_service.log_error message
          raise ApiError, message
        end

        return response
      end

      message = "#{THIRD_PARTY_USER_CREATION_ERROR}: #{e.http_code} | #{e.http_body}"
      @log_service.log_error message
      raise ApiError, message
    end
  end

  def create_order(user, address, products)

    data = {
        :order => {
            :payment_details => {
                :method_id => 'account_funds',
                :method_title => 'VINOS',
                :paid => true
            },
            :billing_address => {
                :phone => user.mobile_number,
            },
            :shipping_address => {
                :first_name => user.first_name,
                :last_name => user.last_name,
                :address_1 => address
            },
            :customer_id => user.third_party_id,
            :line_items => products,
            :shipping_lines => [
                {
                    :method_id => 'distance_rate',
                    :method_title => 'On-Demand Mobile Wine Steward',
                    :total => 0
                }
            ],
            :status => 'pending'
        }
    }

    uri= "#{@config[:product_api_uri]}/orders"
    auth_header = @key_provider.get_product_api_auth_key

    begin
      return @rest_util.execute_post(uri, auth_header, data.to_json)
    rescue RestClient::Exception => e
      message = "#{THIRD_PARTY_ORDER_CREATION_ERROR}: #{e.http_code} | #{e.http_body}"
      @log_service.log_error message
      raise ApiError, message
    end

  end

  def update_order_status(order_id, status)

    data = {
        :order => {
            :status => status
        }
    }

    uri= "#{@config[:product_api_uri]}/orders/#{order_id}"
    auth_header = @key_provider.get_product_api_auth_key

    begin
      return @rest_util.execute_post(uri, auth_header, data.to_json)
    rescue RestClient::Exception => e
      message = "#{THIRD_PARTY_ORDER_UPDATE_ERROR}: #{e.http_code} | #{e.http_body}"
      @log_service.log_error message
      raise ApiError, message
    end

  end
end