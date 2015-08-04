require './api/utils/rest_util'
require './api/utils/key_provider'
require './api/services/config_service'
require 'json'

class WooGateway
  def initialize(rest_util = RestUtil, key_provider = KeyProvider, config_service = ConfigurationService)
    @rest_util = rest_util.new
    @config = config_service.new.get_config
    @key_provider = key_provider.new
  end

  def get_all_products
    uri= "#{@config[:woocommerce_api_uri]}/products?filter[limit]=1000"
    auth_header = @key_provider.get_woocommerce_key

    @rest_util.execute_get(uri, auth_header)
  end
end