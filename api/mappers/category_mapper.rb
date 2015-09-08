require './api/services/config_service'

class CategoryMapper

  def initialize(config_service = ConfigurationService)
    @config = config_service.new.get_config
  end

  def map_categories(categories)
    result = []

    # # get all the top-level categories first
    # categories.each do |category|
    #   if category[:parent] == 0
    #     result << map_category(category)
    #   end
    # end
    #
    # # get the difference in arrays
    # sub_categories = categories - result
    #
    # sub_categories.each do |sub_category|
    #   result.each do |category|
    #     if sub_category[:parent] == category[:id]
    #       category[:sub_categories] << map_category(sub_category)
    #     end
    #   end
    # end

    # top-level categories
    categories.each do |category|
      if category[:parent] == 0
        mapped_category = map_category(category)
        result << mapped_category
      end
    end

    recurse_categories result, categories

  end

  def recurse_categories(mapped_categories, categories)
    mapped_categories.each do |mapped_category|
      mapped_sub_categories = []

      categories.each do |category|
        if mapped_category[:id] == category[:parent]
          sub_category = map_category(category)
          mapped_sub_categories << sub_category
        end
      end

      mapped_category[:sub_categories] = mapped_sub_categories
    end
  end

  def map_category(category)
    currency = nil
    producer = nil
    color = nil
    grapes = []
    style = []
    mood = []

    case category[:type].to_s.downcase
      when 'simple'
        product_type = 'Wine'
        currency = @config[:default_crypto_currency]
      when 'deposit'
        product_type = 'Top-up'
        currency = @config[:default_fiat_currency]
      else
        product_type = category[:type]
    end

    category[:attributes].each do |attribute|

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
    if category[:images] != nil && category[:images].length > 0
      image = category[:images][0][:src]
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
        :product_id => category[:id],
        :product_type => product_type,
        :supplier => 'MyVinos',
        :producer => producer,
        # :brand => brand,
        :price => category[:price],
        :currency => currency,
        :name => category[:title],
        :description => category[:description],
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