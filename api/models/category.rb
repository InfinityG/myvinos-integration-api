module MyVinos
  module Models
    class Category
      include MongoMapper::EmbeddedDocument

      key :name, String
      key :image_url, String

      many :categories, :class_name => 'MyVinos::Models::Category'
    end
  end
end