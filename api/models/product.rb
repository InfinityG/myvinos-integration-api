module MyVinos
  module Models
    class Product
      include MongoMapper::EmbeddedDocument

      # {
      #     "name": "Momento Tinta Barocca (2013)",
      #     "product_type": "wine",
      #     "supplier": "Reserve Wine",
      #     "brand": "Momento",
      #     "tags": {
      #         "color": "Red",
      #         "grapes": "Blend",
      #         "style": "Spicy",
      #         "mood": "Romantic",
      #         "food": []
      #     }
      # }

      key :product_id, String
      key :title, String
      key :description, String
      key :farm, String
      key :color, String
      key :grapes, String
      key :style, String
      key :image_url, String
    end
  end
end