require 'mongo_mapper'
require 'bson'
require './api/models/user'
require './api/models/card'
require './api/models/address'

class UserRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models

  def get_users
    User.all
    end

  def get_all_users(offset=nil, limit=nil, username=nil)
    if offset == nil || limit == nil
      (username == nil) ? User.sort(:username.asc) : User.where(:username => username).sort(:username.asc)
    else
      (username == nil) ?
          User.paginate({:order => :username.asc, :per_page => limit, :page => offset}) :
          User.where(:username => username).paginate({:order => :username.asc, :per_page => limit, :page => offset})
    end
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
  def create(external_id, third_party_id, username, first_name, last_name, email, mobile_number, meta, balance)

    if get_by_username(username) == nil
      User.create(external_id: external_id, third_party_id: third_party_id,
                  username: username, first_name: first_name, last_name: last_name,
                  email: email, mobile_number: mobile_number, meta: meta, balance: balance, pending_balance: 0)
    end
  end

  def update_balance(user_id, balance)
    User.set({:id => user_id}, :balance => balance)
  end

  def update_pending_balance(user_id, pending_balance)
    User.set({:id => user_id}, :pending_balance => pending_balance)
  end

  def update_balance_and_membership_type(user_id, balance, membership_type)
    User.set({:id => user_id}, :balance => balance, :membership_type => membership_type)
    end

  def update_membership_type(user_id, membership_type)
    User.set({:id => user_id}, :membership_type => membership_type)
    end

  def update_role(user_id, role)
    User.set({:id => user_id}, :role => role)
  end

  def update(user, first_name, last_name, email, mobile_number)
    user.first_name = first_name if first_name.to_s != ''
    user.last_name = last_name if last_name.to_s != ''
    user.email = email if email.to_s != ''
    user.mobile_number = mobile_number if mobile_number.to_s != ''

    user.save

    user
  end

  def delete_user(user_id)
    User.destroy(user_id)
  end
end