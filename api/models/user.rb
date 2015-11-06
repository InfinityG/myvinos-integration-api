module MyVinos
  module Models
    class User
      include MongoMapper::Document

      key :external_id, String
      key :third_party_id, String
      key :username, String, :required => true, :key => true
      key :first_name, String
      key :last_name, String
      key :email, String
      key :mobile_number, String
      key :meta, String
      key :balance, Integer
      key :pending_balance, Integer

      # many :addresses, :class_name => 'MyVinos::Models::Address'
      many :orders, :class_name => 'MyVinos::Models::Order'

      timestamps!

    end
  end
end