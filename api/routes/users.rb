require 'sinatra/base'

require './api/validators/api_validator'
require './api/errors/api_error'
require './api/services/user_service'

module Sinatra
  module UserRoutes
    def self.registered(app)

      #get user details
      app.get '/users/:username' do
        content_type :json

        begin
          username = params[:username]
          user_service = UserService.new
          user = user_service.get_by_username(username, @current_user)
          user.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end

      end

      app.get '/users' do
        content_type :json

        begin
          user_service = UserService.new
          user = user_service.get_all
          user.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end

      end

    end

  end
  register UserRoutes
end