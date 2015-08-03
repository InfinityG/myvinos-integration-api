module MyVinos
  module Models
    class Product
      include MongoMapper::EmbeddedDocument

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