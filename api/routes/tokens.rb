require 'sinatra/base'
require './api/services/token_service'
require 'json'

module Sinatra
  module TokenRoutes
    def self.registered(app)

      #create new token: login
      app.post '/tokens' do

        data = JSON.parse(request.body.read, :symbolize_names => true)
        token_service = TokenService.new

        validated_auth = token_service.validate_auth(data[:auth], data[:iv])
        halt 401, 'Unauthorized!' if validated_auth == nil

        # validate the fields of the auth token
        begin
          ApiValidator.new.validate_user_details validated_auth
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        begin
          token = token_service.create_token validated_auth
          status 201
          token.to_json
        rescue ApiError => e
          status 500
          e.message.to_json
        end
      end

    end
  end
  register TokenRoutes
end