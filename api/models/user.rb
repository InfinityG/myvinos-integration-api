module MyVinos
  module Models
    class User
      include MongoMapper::Document

      key :username, String, :required => true, :key => true
      key :first_name, String
      key :last_name, String
      key :email, String
      key :balance, Integer

      many :address, :class_name => 'MyVinos.Models.Address'
      many :orders, :class_name => 'MyVinos::Models::Order'

    end
  end
end