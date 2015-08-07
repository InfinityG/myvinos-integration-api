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

  def save_or_update_user(username, first_name = '', last_name = '', email = '', balance = 0,
                          billing_address = nil, shipping_address = nil)
    user = get_by_username(username)

    if user != nil
      #TOD: complete addresses
      user.first_name = first_name
      user.last_name = last_name
      user.email = email
      user.save
    else
      addresses = []
      addresses << billing_address if billing_address != nil
      addresses << shipping_address if shipping_address != nil

      user = User.create(username: username, first_name: first_name, last_name: last_name,
                         email: email, balance: balance, addresses: addresses)
    end

    user
  end

  def delete_user(user_id)
    User.destroy(user_id)
  end
end