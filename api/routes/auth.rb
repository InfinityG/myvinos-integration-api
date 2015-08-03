require 'sinatra/base'
require './api/services/config_service'
require './api/services/token_service'

module Sinatra
  module AuthRoutes
    def self.registered(app)

      #this filter applies to everything except options, registration of new users and documentation
      app.before do

        method = request.request_method
        path = request.path_info

        if (method == 'OPTIONS') ||
            (method == 'POST' && path == '/users') ||
            (method == 'POST' && path == '/tokens')
          return
        else
          auth_header = env['HTTP_AUTHORIZATION']

          halt 401, 'Unauthorized!' if auth_header == nil

          token = TokenService.new.get_token(auth_header)

          if token == nil
            (halt 401, 'Unauthorized!')
          else
            user = UserService.new.get_by_id token[:user_id]

            @current_user = user
          end
        end

      end

    end
  end

  register AuthRoutes
end