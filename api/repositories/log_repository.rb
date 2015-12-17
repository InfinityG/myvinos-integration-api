require 'mongo_mapper'
require 'bson'
require './api/models/log'

class LogRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models

  def create(user_id, username, operation, description)
    Log.create(:user_id => user_id, :username => username, :operation => operation, :description => description)
  end
end