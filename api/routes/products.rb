# require 'sinatra/base'
# require './api/routes/auth'
require './api/services/product_service'

module Sinatra
  module ProductRoutes
    def self.registered(app)

      #get users
      app.get '/products' do
        content_type :json

        #handle paging
        # index = params[:index].to_i
        # count = params[:count].to_i

        product_service = ProductService.new
        products = product_service.get_products
        return products.to_json
      end

      #get user details
      app.get '/product/:product_id' do
        content_type :json

        product_id = params[:product_id]
      end

    end

  end
  register UserRoutes
end