require 'minitest'
require 'minitest/autorun'

require './api/gateways/product_gateway'

class ProductGatewayTests < MiniTest::Test
  def test_get_all_products
    gateway = ProductGateway.new
    result = gateway.get_all_products

    assert result.response_code == 200
    products = JSON.parse(result.response_body, :symbolize_names => true)[:products]
    assert products.length > 0
  end
end