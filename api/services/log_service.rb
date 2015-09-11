require 'logger'
require 'json'
require './api/services/config_service'

class LogService

  def initialize
    config = ConfigurationService.new.get_config
    @logger = Logger.new config[:logger_file], config[:logger_age], config[:logger_size]
  end

  def log_error(message)
    @logger.error(message)
  end

end