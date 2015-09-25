module MyVinos
  module Models
    class Delivery
      include MongoMapper::Document

      key :status, String
      key :address, String
      key :coordinates, String
      key :mobile_number, String
      key :coordinates, String
      key :notes, String
      key :time_estimate, String
      key :distance_estimate, String
      key :external_id, String

    end
  end
end
