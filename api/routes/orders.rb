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

      # ADMIN - create an order on behalf of a user (currently only supports vin_credit orders)
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

      # gets the orders for the CURRENT USER, with optional filters
      # eg: /admin/orders?offset=1&limit=10&type=mem_purchase
      app.get '/orders' do
        begin
          offset = params[:offset]
          limit = params[:limit]
          type = params[:type]

          orders = OrderService.build.get_orders(@current_user, offset, limit, type)
          status 200
          orders.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end
      end

      # ADMIN ROUTE - gets all orders, with optional filters
      # eg: /admin/orders?offset=1&limit=10&type=mem_purchase&username=bob@test.com
      app.get '/admin/orders' do

        begin

          offset = params[:offset]
          limit = params[:limit]
          type = params[:type]
          username = params[:username]

          orders = OrderService.build.get_all_orders offset, limit, type, username
          json = orders.to_json

          request.accept.each do |accept_type|
            case accept_type.to_s
              when 'text/csv'
                content_type 'application/csv'
                attachment 'orders.csv'
                status 200
                return CsvGenerator.json_to_csv json
              else
                content_type :json
                status 200
                return json
            end
          end
        rescue ApiError => e
          status 500
          return e.message.to_json
        end
      end

    end

  end
  register OrderRoutes
end