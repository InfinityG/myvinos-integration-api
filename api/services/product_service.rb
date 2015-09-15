require './api/gateways/product_gateway'
require './api/constants/error_constants'
require './api/mappers/product_mapper'
require './api/mappers/category_mapper'
require './api/repositories/cache_repository'

class ProductService

  def initialize(config_service = ConfigurationService, product_gateway = ProductGateway,
                 cache_repository = CacheRepository, product_mapper = ProductMapper, category_mapper = CategoryMapper)
    @config = config_service.new.get_config
    @product_gateway = product_gateway.new
    @product_mapper = product_mapper.new
    @category_mapper = category_mapper.new
    @cache_repository = cache_repository.new
  end

  def get_products
    products = @cache_repository.get_products
    return products if (products != nil && products.length > 0)

    repopulate_products_cache
  end

  def get_product(product_id)
    product = @cache_repository.get_product(product_id)
    return product if product != nil

    repopulate_products_cache
    @cache_repository.get_product(product_id)

    # response = @product_gateway.get_product(product_id)
    #
    # raise ApiError, THIRD_PARTY_PRODUCT_REQUEST_ERROR if response.response_code != 200
    # result = JSON.parse(response.response_body, :symbolize_names => true)
    #
    # @product_mapper.map_product result[:product]

  end

  def repopulate_products_cache
    # get the products
    products_response = @product_gateway.get_all_products
    raise ApiError, THIRD_PARTY_PRODUCT_REQUEST_ERROR if products_response.response_code != 200

    # get the categories
    categories_response = @product_gateway.get_all_categories
    raise ApiError, THIRD_PARTY_CATEGORY_REQUEST_ERROR if products_response.response_code != 200

    products_result = JSON.parse(products_response.response_body, :symbolize_names => true)
    categories_result = JSON.parse(categories_response.response_body, :symbolize_names => true)

    mapped_categories = @category_mapper.map_categories categories_result[:product_categories]
    mapped_products = @product_mapper.map_products products_result[:products], mapped_categories

    timeout = (Time.now + @config[:cache_timeout]).to_i

    @cache_repository.save_products(mapped_products, timeout)
  end

  # def get_category_tree_for_product(category_id)
  #   categories = @cache_repository.get_categories
  #
  # end

end