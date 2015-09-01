require './api/models/user'
require './api/repositories/user_repository'
require './api/services/hash_service'
require './api/gateways/product_gateway'
require './api/constants/error_constants'
require './api/errors/api_error'

class UserService

  include ErrorConstants::ApiErrors

  def initialize(user_repository = UserRepository, hash_service = HashService, product_gateway = ProductGateway)
    @user_repository = user_repository.new
    @hash_service = hash_service.new
    @product_gateway = product_gateway.new
  end

  def create_or_update(validated_auth)
    username = validated_auth[:username]
    user = get_by_username username

    return user if (user != nil && user.third_party_id.to_s != '')

    external_id = validated_auth[:id] # this is the user id generated by ID-IO
    first_name = validated_auth[:first_name]
    last_name = validated_auth[:last_name]
    email = validated_auth[:email]

    # create new user on third_party
    third_party_user_result = @product_gateway.create_user username, email, first_name, last_name

    # create user on local db
    new_external_user = JSON.parse(third_party_user_result.response_body, :symbolize_names => true)
    third_party_id = new_external_user[:customer][:id].to_s
    @user_repository.create external_id, third_party_id, username, first_name, last_name, email

  end

  #TODO: refactor this to handle paging
  def get_all
    @user_repository.get_all_users
  end

  def get_by_id(user_id)
    @user_repository.get_user user_id.to_s
  end

  def get_by_username(username)
    @user_repository.get_by_username username
  end

  def update(username, first_name, last_name, password)
    #TODO: update the DB - username is the identifier and cannot be changed
    raise 'User update not implemented'
  end

  def update_balance(user_id, amount)
    user = get_by_id user_id
    user.balance += amount
    user.save

    user.balance
  end

  def delete(username)
    #TODO: delete from the DB - username is the identifier
    raise 'User delete not implemented'
  end

end