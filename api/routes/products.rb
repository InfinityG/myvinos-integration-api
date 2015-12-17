require './api/services/product_service'

module Sinatra
  module ProductRoutes
    def self.registered(app)

      app.get '/products' do
        content_type :json

        #handle paging
        # index = params[:index].to_i
        # count = params[:count].to_i

        begin
          product_service = ProductService.new
          products = product_service.get_products
          return products.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end

      end

      app.get '/products/:product_id' do
        content_type :json

        product_id = params[:product_id]

        content_type :json

        begin
          product_service = ProductService.new
          product = product_service.get_product product_id
          return product.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end
      end

    end

  end
  register UserRoutes
end