#config.ru
# see http://bundler.io/v1.3/sinatra.html

require './app'
require 'rack'
require './api/services/config_service'

ApiApp.run!

# start this with 'rackup' to start in development environment. Switch '-p' for port is not required as this is detected
# from configuration. eg:

# 'rackup -E development' for development environment
# 'rackup -E test' for test environment
# 'rackup -E production' for production environment