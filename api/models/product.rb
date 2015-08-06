module MyVinos
  module Models
    class Product
      include MongoMapper::EmbeddedDocument

      key :product_id, String
      key :product_type, String
      key :supplier, String
      key :brand, String
      key :price, String
      key :currency, String
      key :name, String
      key :description, String
      key :image_url, String
      key :tags, Hash
    end
  end
end