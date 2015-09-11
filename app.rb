require 'sinatra/base'
require 'openssl'
require 'webrick'
require 'webrick/https'
require 'mongo'
require 'mongo_mapper'

require './api/routes/cors'
require './api/routes/auth'
require './api/routes/users'
require './api/routes/products'
require './api/routes/orders'
require './api/routes/tokens'
require './api/services/config_service'
require './api/services/queue_processor_service'

class ApiApp < Sinatra::Base

  configure do
    config = ConfigurationService.new.get_config

    puts 'Setting up database...'
    MongoMapper.connection = Mongo::MongoClient.new(config[:mongo_host], config[:mongo_port])
    MongoMapper.database = config[:mongo_db]
    # MongoMapper.database.authenticate(config[:mongo_db_user], config[:mongo_db_password]) if config[:mongo_host] != 'localhost'

    puts 'Setting up routes...'
    register Sinatra::CorsRoutes
    register Sinatra::AuthRoutes
    register Sinatra::TokenRoutes
    register Sinatra::UserRoutes
    register Sinatra::ProductRoutes
    register Sinatra::OrderRoutes

    puts 'Starting queue processor service...'
    queue_service = QueueProcessorService.new
    queue_service.start
  end

  #http://stackoverflow.com/questions/2362148/how-to-enable-ssl-for-a-standalone-sinatra-app
  def self.run!
    # Signal.trap('INT') {
    #   Rack::Handler::WEBrick.shutdown
    # }

    options = ConfigurationService.new.get_server_config

    # run ApiApp
    Rack::Handler::WEBrick.run self, options do |server|
      # Ctrl-C produces INT signal to stop
      [:INT, :TERM].each do |sig|
        trap(sig) do
          server.shutdown
        end
      end
    end
  end

end