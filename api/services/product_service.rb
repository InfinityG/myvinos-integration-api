require './api/utils/rest_util'
require './api/services/config_service'
require './api/utils/key_provider'
require './api/constants/error_constants'
require './api/mappers/product_mapper'
require './api/repositories/cache_repository'

class ProductService

  def initialize(rest_util = RestUtil, key_provider = KeyProvider, config_service = ConfigurationService,
                 cache_repository = CacheRepository, mapper = ProductMapper)
    @rest_util = rest_util.new
    @key_provider = key_provider.new
    @config = config_service.new.get_config
    @mapper = mapper.new
    @cache_repository = cache_repository.new
  end

  def get_products
    products = @cache_repository.get_products
    return products if (products != nil && products.length > 0)

    uri= "#{@config[:woocommerce_api_uri]}/products?filter[limit]=1000"
    auth_header = @key_provider.get_woocommerce_key

    response = @rest_util.execute_get(uri, auth_header)

    if response.response_code == 200
      result = JSON.parse(response.response_body, :symbolize_names => true)
      mapped_products = @mapper.map_woo_products result[:products]
      timeout = (Time.now + @config[:cache_timeout]).to_i

      @cache_repository.save_products mapped_products, timeout

      mapped_products
    else
      raise ApiError, WOOCOMMERCE_REQUEST_ERROR
    end

  end

end