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
    currency = nil
    producer = nil
    color = nil
    grapes = []
    style = []
    mood = []

    case product[:type].to_s.downcase
      when 'simple'
        product_type = 'Wine'
        currency = @config[:default_crypto_currency]
      when 'deposit'
        product_type = 'Top-up'
        currency = @config[:default_fiat_currency]
      else
        product_type = product[:type]
    end

    product[:attributes].each do |attribute|

      if attribute[:options] != nil && attribute[:options].length > 0

        producer = attribute[:options][0] if attribute[:name].to_s.downcase == 'producer'
        color = attribute[:options][0] if attribute[:name].to_s.downcase == 'wine'

        if attribute[:name].to_s.downcase == 'grapes'
          attribute[:options].each do |option|
            grapes << option
          end
        end

        if attribute[:name].to_s.downcase == 'style'
          attribute[:options].each do |option|
            style << option
          end
        end

        if attribute[:name].to_s.downcase == 'mood'
          attribute[:options].each do |option|
            mood << option
          end
        end

      end
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
        :supplier => 'MyVinos',
        :producer => producer,
        # :brand => brand,
        :price => product[:price],
        :currency => currency,
        :name => product[:title],
        :description => product[:description],
        :image_url => image,
        :tags => {

            :color => color,
            :grapes => grapes,
            :style => style,
            :mood => mood
        }
    }
  end
end