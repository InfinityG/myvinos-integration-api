require './api/services/config_service'

module RateUtil
  def self.convert_fiat_to_vin(fiat)
    config = ConfigurationService.new.get_config
    rate = config[:exchange_rate]
    return fiat * rate
    end

  def self.convert_vin_to_fiat(vin)
    config = ConfigurationService.new.get_config
    rate = config[:exchange_rate]
    return (vin / rate).to_i
  end
end