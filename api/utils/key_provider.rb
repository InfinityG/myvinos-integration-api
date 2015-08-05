require 'base64'
require './api/services/config_service'

class KeyProvider
  def get_product_api_auth_key
    config = ConfigurationService.new.get_config
    encoded = Base64.strict_encode64("#{config[:product_api_key]}:#{config[:product_api_secret]}").chomp  #.gsub('=', '')
    "Basic #{encoded}"
  end
end