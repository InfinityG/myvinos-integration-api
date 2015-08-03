require 'base64'
require './api/services/config_service'

class KeyProvider
  def get_woocommerce_key
    config = ConfigurationService.new.get_config
    encoded = Base64.strict_encode64("#{config[:woocommerce_api_key]}:#{config[:woocommerce_api_secret]}").chomp  #.gsub('=', '')
    "Basic #{encoded}"
  end
end