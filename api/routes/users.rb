require 'sinatra/base'

require './api/validators/api_validator'
require './api/errors/api_error'
require './api/services/user_service'
require './api/utils/csv_generator'

module Sinatra
  module UserRoutes
    def self.registered(app)

      #get user details
      app.get '/users/:username' do
        content_type :json

        begin
          username = params[:username]
          user_service = UserService.new
          user = user_service.get_by_username_with_cards(username, @current_user)
          # user = user_service.get_by_username(username, @current_user)
          user.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end

      end

      # ADMIN ROUTE
      app.get '/admin/users' do

        begin
          offset = params[:offset]
          limit = params[:limit]
          username = params[:username]

          user_service = UserService.new
          user = user_service.get_all offset, limit, username
          json = user.to_json

          request.accept.each do |accept_type|
            case accept_type.to_s
              when 'text/csv'
                content_type 'application/csv'
                attachment 'users.csv'
                return CsvGenerator.json_to_csv json
              else
                content_type :json
                return json
            end
          end

          # user.to_json
        rescue ApiError => e
          status 500
          return e.message.to_json
        end
        end

    end

  end
  register UserRoutes
end