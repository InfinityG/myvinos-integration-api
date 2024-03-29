module MyVinos
  module Models
    class Product
      include MongoMapper::EmbeddedDocument

      key :product_id, String
      key :product_type, String
      key :price, String
      key :currency, String
      key :name, String
      key :description, String
      key :image_url, String
      key :stock_quantity, Integer
      key :tags, Hash
      key :sort_index_1, Integer
      key :sort_index_2, Integer

      many :categories, :class_name => 'MyVinos::Models::Category'
    end
  end
end