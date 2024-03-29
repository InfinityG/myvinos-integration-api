require './api/constants/api_constants'
require './api/services/config_service'
require './api/mappers/category_mapper'

class ProductMapper

  include ApiConstants

  def initialize(config_service = ConfigurationService, category_mapper = CategoryMapper)
    @config = config_service.new.get_config
    @category_mapper = category_mapper.new
  end

  def map_products(products, mapped_categories)
    result = []

    # only map in-stock products
    products.each do |product|
      result << map_product(product, mapped_categories) if product[:in_stock]
    end

    result
  end

  def map_product(product, mapped_categories)
    currency = nil
    producer = nil
    grapes = nil
    style = nil
    region = nil
    vintage = nil
    score_1 = nil
    score_2 = nil
    score_3 = nil
    sort_index = 0

    case product[:type].to_s.downcase
      when 'simple'
        (product[:tags].include? 'Delivery') ? product_type = DELIVERY_PRODUCT_TYPE : product_type = WINE_PRODUCT_TYPE
        currency = @config[:default_crypto_currency]
      when 'deposit'
        # product_type = TOP_UP_PRODUCT_TYPE
        (product[:tags].include? 'Membership') ? product_type = MEMBERSHIP_PRODUCT_TYPE : product_type = TOP_UP_PRODUCT_TYPE
        currency = @config[:default_fiat_currency]
      else
        product_type = product[:type]
    end

    product[:attributes].each do |attribute|

      if attribute[:options] != nil && attribute[:options].length > 0

        producer = attribute[:options][0] if attribute[:name].to_s.downcase == 'producer'
        region = attribute[:options][0] if attribute[:name].to_s.downcase == 'region'

        if attribute[:name].to_s.downcase == 'grapes'
          grapes = attribute[:options][0]

          case grapes.to_s.downcase
            when 'sparkling'
              sort_index = 1
            when 'white'
              sort_index = 2
            when 'rose'
              sort_index = 3
            when 'red'
              sort_index = 4
            when 'dessert'
              sort_index = 5
            else
              sort_index = 6
          end

        end

        style = attribute[:options][0] if attribute[:name].to_s.downcase == 'style'
        vintage = attribute[:options][0] if attribute[:name].to_s.downcase == 'vintage'

      end
    end

    # image
    image = nil
    if product[:images] != nil && product[:images].length > 0
      image = product[:images][0][:src]
    end

    categories = build_categories product, mapped_categories

    {
        :product_id => product[:id],
        :product_type => product_type,
        :price => product[:price],
        :currency => currency,
        :name => product[:title],
        :description => product[:description],
        :stock_quantity => product[:stock_quantity],
        :image_url => image,
        :tags => {
            :grapes => grapes,
            :style => style,
            :region => region,
            :producer => producer,
            :vintage => vintage,
            :score_1 => score_1,
            :score_2 => score_2,
            :score_3 => score_3
        },
        :categories => categories,
        :sort_index_1 => sort_index
    }
  end

  # recursively build categories specific to each product
  def build_categories(product, mapped_categories)
    collection = []

    product[:categories].each do |category_name|
      mapped_categories.each do |mapped_category|
        build_category_tree(collection, category_name, mapped_category)
      end
    end

    collection
  end

  def build_category_tree(collection, category_name, mapped_category)
    if mapped_category[:child_index].include?(category_name) || mapped_category[:name] == category_name
      current_category = {
          :name => mapped_category[:name],
          :slug => mapped_category[:slug],
          :categories => [],
          :image_url => mapped_category[:image_url],
          :description => mapped_category[:description]
      }

      mapped_category[:categories].each do |category|
        build_category_tree current_category[:categories], category_name, category
      end

      collection << current_category
    end
  end

end