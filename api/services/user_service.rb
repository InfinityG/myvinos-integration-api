require './api/models/user'
require './api/repositories/user_repository'
require './api/services/hash_service'

class UserService

  def initialize(user_repository = UserRepository, hash_service = HashService)
    @user_repository = user_repository.new
    @hash_service = hash_service.new
  end

  def create(first_name, last_name, password, username)
    #create salt and hash
    salt = @hash_service.generate_salt
    hashed_password = @hash_service.generate_password_hash password, salt

    begin
      user = @user_repository.save_or_update_user first_name, last_name, username, salt, hashed_password
      log(user.id, 'UserService', nil, 'create', 'Create user')

      user
    rescue
      raise "Unable to save user #{username} on database! || Error: #{$!}"
    end
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
  end

  def delete(username)
    #TODO: delete from the DB - username is the identifier
    raise 'User delete not implemented'
  end

end