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

  def get_all_with_pending_balance
    User.where(:$and => [{:pending_balance.ne => 0}, {:pending_balance.ne => nil}]).all
  end

  # only create the user if it doesn't already exist
  def create(external_id, third_party_id, username, first_name, last_name, email, mobile_number, balance)

    if get_by_username(username) == nil
      User.create(external_id: external_id, third_party_id: third_party_id,
                  username: username, first_name: first_name, last_name: last_name,
                  email: email, mobile_number: mobile_number, balance: balance, pending_balance: 0)
    end
  end

  # def update(username, first_name = '', last_name = '', email = '', balance = 0,
  #                         billing_address = nil, shipping_address = nil)
  #
  #   # user will always exist as the token creation process will auto-create the user
  #   user = get_by_username(username)
  #
  #   # # user already exists
  #   # user.first_name = first_name
  #   # user.last_name = last_name
  #   # user.email = email
  #   # user.save
  #
  #
  #   addresses = []
  #   addresses << billing_address if billing_address != nil
  #   addresses << shipping_address if shipping_address != nil
  #
  #   User.create(username: username, first_name: first_name, last_name: last_name,
  #                      email: email, balance: balance, addresses: addresses)
  # end

  def delete_user(user_id)
    User.destroy(user_id)
  end
end