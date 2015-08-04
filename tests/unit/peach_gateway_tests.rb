require 'minitest'
require 'minitest/autorun'

require './api/gateway/peach_gateway'

class PeachGatewayTests < MiniTest::Test

  def test_checkout_request
    gateway = PeachGateway.new

    result = gateway.send_checkout_request('DB', '20.00', 'ZAR')

    assert result.response_code == 200
  end
end