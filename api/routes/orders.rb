# require 'sinatra/base'
# require './api/routes/auth'
require './api/services/product_service'
require './api/validators/api_validator'
require './api/errors/api_error'

module Sinatra
  module OrderRoutes
    def self.registered(app)

      app.post '/orders' do

        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
          ApiValidator.new.validate_order data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        begin
          order = OrderService.build.create_order(@current_user, data)
          status 201
          order.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end
      end

      app.get '/orders' do
        begin
          orders = OrderService.build.get_orders(@current_user)
          status 201
          orders.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end
      end
    end

  end
  register OrderRoutes
end