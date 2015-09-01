require 'sinatra/base'

require './api/validators/api_validator'
require './api/errors/api_error'
require './api/services/user_service'

module Sinatra
  module UserRoutes
    def self.registered(app)

      #get user details
      app.get '/users/:user_id' do
        content_type :json

        user_id = params[:user_id]
        user_service = UserService.new
        user = user_service.get_by_id user_id
        user.to_json
        end

      app.get '/users' do
        content_type :json

        user_service = UserService.new
        user = user_service.get_all
        user.to_json
      end

    end

  end
  register UserRoutes
end