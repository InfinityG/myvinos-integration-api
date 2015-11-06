module MyVinos
  module Models
    class Card
      include MongoMapper::Document

      key :user_id, String

      key :registration_id, String
      key :last_4_digits, Integer
      key :holder, String
      key :expiry_month, Integer
      key :expiry_year, Integer
      key :default, Boolean

      timestamps!

    end
  end
end