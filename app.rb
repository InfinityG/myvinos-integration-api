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
require './api/services/balance_processor_service'

class ApiApp < Sinatra::Base

  # set up some lambdas

  configure_db = lambda do |config|
    if config[:mongo_replicated] == 'true'
      MongoMapper.connection = Mongo::MongoReplicaSetClient.new([config[:mongo_host_1], config[:mongo_host_2], config[:mongo_host_3]])
    else
      conn_pair = config[:mongo_host_1].split(':')
      MongoMapper.connection = Mongo::MongoClient.new(conn_pair[0], conn_pair[1])
    end

    MongoMapper.database = config[:mongo_db]
  end

  configure_routes = lambda do
    register Sinatra::CorsRoutes
    register Sinatra::AuthRoutes
    register Sinatra::TokenRoutes
    register Sinatra::UserRoutes
    register Sinatra::ProductRoutes
    register Sinatra::OrderRoutes
  end

  configure_queue_processor = lambda do
    queue_service = QueueProcessorService.new
    queue_service.start
  end

  configure_balance_processor = lambda do
    balance_service = BalanceProcessorService.new
    balance_service.start
  end

  configure do
    config = ConfigurationService.new.get_config

    puts 'Setting up database...'
    configure_db.call config

    puts 'Setting up routes...'
    configure_routes.call

    puts 'Starting checkout queue processor service...'
    configure_queue_processor.call

    puts 'Starting pending balance processor service...'
    configure_balance_processor.call
  end

  #http://stackoverflow.com/questions/2362148/how-to-enable-ssl-for-a-standalone-sinatra-app
  def self.run!
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