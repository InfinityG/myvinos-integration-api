require '../../api/services/config_service'

module RateUtil
  def self.convert_fiat_to_vin(fiat)
    config = ConfigurationService.new.get_config
    rate = config[:exchange_rate]
    fiat * rate
  end
end