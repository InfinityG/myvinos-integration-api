module MyVinos
  module Models
    class Address
      include MongoMapper::EmbeddedDocument

      key :type, String # billing or delivery
      key :line_1, String
      key :line_2, String
      key :city, String
      key :state, String
      key :postcode, String
      key :country, String
      key :email, String
      key :phone, String
    end
  end
end