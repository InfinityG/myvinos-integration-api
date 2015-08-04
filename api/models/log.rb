module MyVinos
  module Models
    class Log
      include MongoMapper::Document

      key :user_id, String
      key :type, String
      key :type_id, String
      key :operation, String
      key :description, String

      timestamps!
    end
  end
end