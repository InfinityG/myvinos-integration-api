module MyVinos
  module Models
    class Transaction
      include MongoMapper::EmbeddedDocument

      key :type, String
      key :external_transaction_id, String
      key :checkout_id, String
      key :amount, String
      key :currency, String
      key :status, String
      key :memo, String

      timestamps!

    end
  end
end