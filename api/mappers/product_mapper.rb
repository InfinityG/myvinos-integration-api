require './api/services/config_service'

class ProductMapper

  def initialize(config_service = ConfigurationService)
    @config = config_service.new.get_config
  end

  def map_products(products)
    result = []

    # only map in-stock products
    products.each do |product|
      result << map_product(product) if product[:in_stock]
    end

    result
  end

  def map_product(product)
    product_type = nil
    currency = nil
    brand = nil
    color = nil
    grapes = nil
    style = nil

    product[:categories].each do |category|
      case category.to_s.downcase
        when 'red'
          product_type = 'wine'
          currency = @config[:default_crypto_currency]
          break
        when 'white'
          product_type = 'wine'
          currency = @config[:default_crypto_currency]
          break
        when 'buy'
          product_type = 'vinos'
          currency = @config[:default_fiat_currency]
          break
        else
          product_type = category
          currency = @config[:default_crypto_currency]
      end
    end

    product[:attributes].each do |attribute|
      brand = attribute[:options][0] if attribute[:name] == 'Producer' if attribute[:options] != nil && attribute[:options].length > 0
      color = attribute[:options][0] if attribute[:name] == 'Wine' if attribute[:options] != nil && attribute[:options].length > 0
      grapes = attribute[:options][0] if attribute[:name] == 'Grapes' if attribute[:options] != nil && attribute[:options].length > 0
      style = attribute[:options][0] if attribute[:name] == 'Style' if attribute[:options] != nil && attribute[:options].length > 0
    end

    # image
    image = nil
    if product[:images] != nil && product[:images].length > 0
      image = product[:images][0][:src]
    end

    # {
    #     "name": "Momento Tinta Barocca (2013)",
    #     "product_type": "wine",
    #     "supplier": "Reserve Wine",
    #     "brand": "Momento",
    #     "price": 20,
    #     "currency": "VIN",
    #     "image_url": "",
    #     "tags": {
    #         "color": "Red",
    #         "grapes": "Blend",
    #         "style": "Spicy",
    #         "mood": "Romantic",
    #         "food": []
    #     }
    # }

    {
        :product_id => product[:id],
        :product_type => product_type,
        :supplier => nil,
        :brand => brand,
        :price => product[:price],
        :currency => currency,
        :name => product[:title],
        :description => product[:description],
        :image_url => image,
        :tags => {

            :color => color,
            :grapes => grapes,
            :style => style
        }
    }
  end
end