require './api/constants/configuration_constants'
require 'openssl'

class ConfigurationService
  include ConfigurationConstants::Environments

  def get_config

    case ENV['RACK_ENV']
      when 'test'
        TEST
      when 'production'
        PRODUCTION
      else
        DEVELOPMENT
    end
  end

  def get_server_config
    case ENV['RACK_ENV']
      when 'test'
        {
            :Host => TEST[:host],
            :Port => TEST[:port]
        }
      when 'production'
        {
            :Host => PRODUCTION[:host],
            :Port => PRODUCTION[:port]
        }
      else
        {
            :Host => DEVELOPMENT[:host],
            :Port => DEVELOPMENT[:port]
        }
    end
  end
end