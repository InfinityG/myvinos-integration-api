require './api/gateways/product_gateway'
require './api/constants/error_constants'
require './api/mappers/product_mapper'
require './api/repositories/cache_repository'

class ProductService

  def initialize(config_service = ConfigurationService, product_gateway = ProductGateway,
                 cache_repository = CacheRepository, mapper = ProductMapper)
    @config = config_service.new.get_config
    @product_gateway = product_gateway.new
    @mapper = mapper.new
    @cache_repository = cache_repository.new
  end

  def get_products
    products = @cache_repository.get_products
    return products if (products != nil && products.length > 0)

    response = @product_gateway.get_all_products

    if response.response_code == 200
      result = JSON.parse(response.response_body, :symbolize_names => true)
      mapped_products = @mapper.map_products result[:products]
      timeout = (Time.now + @config[:cache_timeout]).to_i

      @cache_repository.save_products(mapped_products, timeout).products

      # mapped_products
    else
      raise ApiError, PRODUCT_REQUEST_ERROR
    end

  end

  def get_product(product_id)
    product = @cache_repository.get_product(product_id)
    return product if product != nil

    response = @product_gateway.get_product(product_id)

    if response.response_code == 200
      result = JSON.parse(response.response_body, :symbolize_names => true)
      @mapper.map_product result[:product]
    else
      raise ApiError, PRODUCT_REQUEST_ERROR
    end

  end

end