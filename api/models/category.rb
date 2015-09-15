module MyVinos
  module Models
    class Category
      include MongoMapper::EmbeddedDocument

      # key :category_id, String
      key :name, String
      key :image, String
      # key :child_index, Array

      many :categories, :class_name => 'MyVinos::Models::Category'
    end
  end
end