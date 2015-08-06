require 'mongo_mapper'
require 'bson'
require './api/models/user'
require './api/models/address'

class UserRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models

  def get_all_users
    User.all
  end

  def get_user(user_id)
    User.find user_id
  end

  def get_by_username(username)
    User.first(:username => username)
  end

  def save_or_update_user(username, first_name = nil, last_name = nil, email = nil, billing_address = nil, shipping_address = nil)
    user = get_by_username(username)

    if user != nil
      #TOD: complete addresses
      user.first_name = first_name
      user.last_name = last_name
      user.email = email
      user.save
    else
      user = User.create(username: username, first_name: first_name, last_name: last_name,
                         email: email, billing_address: billing_address, shipping_address: shipping_address)
    end

    user
  end

  def delete_user(user_id)
    User.destroy(user_id)
  end
end