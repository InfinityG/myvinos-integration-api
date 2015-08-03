module MyVinos
  module Models
    class Token
      include MongoMapper::Document

      key :user_id, String
      key :external_id, String
      key :uuid, String,  :key => true
      key :expires, Integer
    end
  end
end