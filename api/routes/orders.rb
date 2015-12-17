# require 'sinatra/base'
# require './api/routes/auth'
require './api/services/product_service'
require './api/validators/api_validator'
require './api/errors/api_error'

require './api/utils/csv_generator'

module Sinatra
  module OrderRoutes
    def self.registered(app)

      app.post '/orders' do

        body = request.body.read

        config = ConfigurationService.new.get_config

        if config[:force_ascii_conversion]
          encoded = body.force_encoding('ISO-8859-1').encode!('UTF-8')
          data = JSON.parse(encoded, :symbolize_names => true)
        else
          data = JSON.parse(body, :symbolize_names => true)
        end

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

      app.post '/admin/orders' do

        body = request.body.read
        data = JSON.parse(body, :symbolize_names => true)

        begin
          ApiValidator.new.validate_order data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        begin
          order = OrderService.build.create_admin_order(@current_user, data)
          status 201
          order.to_json
        rescue ApiError => e
          status 400
          return e.message.to_json
        end
      end

      # gets the orders for the CURRENT USER
      app.get '/orders' do
        begin
          orders = OrderService.build.get_orders(@current_user)
          status 200
          orders.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end
      end

      # ADMIN ROUTE - gets all orders - /admin/orders?page=1&count=10

      # app.get '/admin/orders' do
      #   begin
      #     orders = OrderService.build.get_all_orders(page, count)
      #     status 200
      #     CsvGenerator.json_to_csv orders.to_json
      #
      #
      #   rescue ApiError => e
      #     status 500
      #     return e.message.to_json
      #   end
      # end

    end

  end
  register OrderRoutes
end