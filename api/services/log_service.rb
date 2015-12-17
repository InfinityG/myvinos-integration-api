require 'logger'
require 'json'
require './api/services/config_service'
require './api/repositories/log_repository'

class LogService

  def initialize
    config = ConfigurationService.new.get_config
    @logger = Logger.new config[:logger_file], config[:logger_age], config[:logger_size]
  end

  def log_error(message)
    @logger.error(message)
    end

  def log_operation(user, operation, description)
    LogRepository.new.create user.id, user.username, operation, description
  end

end