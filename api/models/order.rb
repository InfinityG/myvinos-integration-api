module MyVinos
  module Models
    class Order
      include MongoMapper::Document

      key :type, String
      key :external_order_id, String
      key :transaction_id, String
      key :line_items, Array

      many :products, :class_name => 'MyVinos::Models::Product'

      timestamps!
    end
  end
end