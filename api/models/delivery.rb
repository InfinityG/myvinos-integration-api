module MyVinos
  module Models
    class Delivery
      include MongoMapper::Document

      key :status, String
      key :address, String
      key :coordinates, String
      key :phone, String

    end
  end
end
