module MyVinos
  module Models
    class Order
      include MongoMapper::Document

      key :type, String
      key :user_id, String
      key :external_order_id, String

      one :transaction, :class_name => 'MyVinos::Models::Transaction'
      many :products, :allow_nil => true, :class_name => 'MyVinos::Models::Product'

      timestamps!
    end
  end
end