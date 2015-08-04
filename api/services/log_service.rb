require './api/repositories/log_repository'

module LogService
  def log(user_id, type, type_id, operation, description)
    # user_id = @current_user.id
    log_repository = LogRepository.new
    log_repository.create(user_id, type, type_id, operation, description)
  end
end