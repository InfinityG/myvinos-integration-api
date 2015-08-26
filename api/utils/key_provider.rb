require 'base64'
require './api/services/config_service'

class KeyProvider
  def get_product_api_auth_key
    config = ConfigurationService.new.get_config
    encoded = Base64.strict_encode64("#{config[:product_api_key]}:#{config[:product_api_secret]}").chomp  #.gsub('=', '')
    "Basic #{encoded}"
  end

  def get_delivery_api_auth
    config = ConfigurationService.new.get_config
    encoded_auth = Base64.strict_encode64("#{config[:delivery_api_key]}:").chomp
    "Basic #{encoded_auth}"
  end
end