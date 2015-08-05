require './api/utils/rest_util'
require './api/utils/key_provider'
require './api/services/config_service'
require 'json'

class ProductGateway
  def initialize(rest_util = RestUtil, key_provider = KeyProvider, config_service = ConfigurationService)
    @rest_util = rest_util.new
    @config = config_service.new.get_config
    @key_provider = key_provider.new
  end

  def get_all_products
    uri= "#{@config[:product_api_uri]}/products?filter[limit]=1000"
    auth_header = @key_provider.get_product_api_auth_key

    @rest_util.execute_get(uri, auth_header)
  end
end