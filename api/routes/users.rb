require 'sinatra/base'

require './api/validators/api_validator'
require './api/errors/api_error'
require './api/services/user_service'

module Sinatra
  module UserRoutes
    def self.registered(app)

      # update user details
      app.post '/users' do
        # content_type :json
        #
        # data = JSON.parse(request.body.read, :symbolize_names => true)
        #
        # begin
        #   ApiValidator.new.validate_user_details data
        # rescue ValidationError => e
        #   status 400 # bad request
        #   return e.message
        # end
        #
        # begin
        #   #create new user
        #   user = UserService.new.update(data, user)
        #   status 201
        #   user.to_json
        # rescue ApiError => e
        #   status 500
        #   return e.message.to_json
        # end
      end

      # #get users
      # app.get '/users' do
      #   content_type :json
      #
      #   #handle paging
      #   index = params[:index].to_i
      #   count = params[:count].to_i
      #
      #   user_service = UserService.new
      #   users = user_service.get_all
      #   total_count = users.length
      #
      #   if index > 0 && count > 0
      #
      #     start_index = (index * count) - count
      #     filtered_users = users[start_index, count]
      #     total_page_count = total_count/count + (total_count%count)
      #
      #     return {
      #         :total_page_count => total_page_count,
      #         :current_page => index,
      #         :total_record_count => total_count,
      #         :page_record_count => filtered_users.length,
      #         :start_index => start_index,
      #         :end_index => start_index + (filtered_users.length - 1),
      #         :users => filtered_users
      #     }.to_json
      #   end
      #
      #   {
      #       :total_page_count => 1,
      #       :current_page => 1,
      #       :total_record_count => total_count,
      #       :page_record_count => total_count,
      #       :start_index => 0,
      #       :end_index => total_count - 1,
      #       :users => users
      #   }.to_json
      # end

      #get user details
      app.get '/users/:user_id' do
        content_type :json

        user_id = params[:user_id]
        user_service = UserService.new
        user = user_service.get_by_id user_id
        user.to_json
      end

    end

  end
  register UserRoutes
end