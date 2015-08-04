require 'mongo_mapper'
require 'bson'
require './api/models/log'

class LogRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models

  def create(user_id, type, type_id, operation, description)
    Log.create(:user_id => user_id, :type => type, :type_id => type_id, :operation => operation, :description => description)
  end
end