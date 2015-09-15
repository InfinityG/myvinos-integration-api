module MyVinos
  module Models
    class Product
      include MongoMapper::EmbeddedDocument

      key :category_id, String
      key :product_type, String
      key :supplier, String
      key :brand, String
      key :price, String
      key :currency, String
      key :name, String
      key :description, String
      key :image_url, String
      key :tags, Hash

      many :categories, :class_name => 'MyVinos::Models::Category'
    end
  end
end