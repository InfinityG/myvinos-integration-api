require 'minitest'
require 'minitest/autorun'

require './api/utils/rate_util'

class ExchangeConversionTests < MiniTest::Test

  def test_convert_fiat
    converted = RateUtil.convert_fiat_to_vin 200

    assert converted == 20
  end
end