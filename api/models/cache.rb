

module MyVinos
  module Models
    class Cache
      include MongoMapper::Document

      key :products_expiry, Integer

      many :products, :class_name => 'MyVinos::Models::Product'
    end
  end
end
