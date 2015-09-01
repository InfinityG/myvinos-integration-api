require 'minitest'
require 'minitest/autorun'

require './api/gateways/payment_gateway'

class PaymentGatewayTests < MiniTest::Test

  def test_checkout_request
    gateway = PaymentGateway.new
    result = gateway.send_checkout_request('DB', '20.00', 'ZAR')

    assert result.response_code == 200
  end
end