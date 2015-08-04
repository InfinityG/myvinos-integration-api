module MyVinos
  module Models
    class Transaction
      include MongoMapper::Document

      key :user_id, String
      key :type, String
      key :order_id, String
      key :checkout_id, String
      key :amount, String
      key :currency, String
      key :status, String

      timestamps!

    end
  end
end