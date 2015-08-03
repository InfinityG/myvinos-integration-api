require 'sinatra/base'
require './api/services/token_service'
require 'json'

module Sinatra
  module TokenRoutes
    def self.registered(app)

      #create new token: login
      app.post '/tokens' do
        data = JSON.parse(request.body.read, :symbolize_names => true)

        auth = data[:auth]
        iv = data[:iv]

        if auth.to_s != '' && iv.to_s != ''
          token = TokenService.new.create_token auth, iv

          if token == nil
            halt 401, 'Unauthorized!'
          end

          token.to_json

        else
          halt 401, 'Unauthorized!'
        end
      end

    end
  end
  register TokenRoutes
end