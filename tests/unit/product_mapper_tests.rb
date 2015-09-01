require 'minitest'
require 'minitest/autorun'
require 'json'

require './api/mappers/product_mapper'

class ProductMapperTests < MiniTest::Test

  def test_map_product_list
    file = File.read('./tests/data/woo_samples/products.json')

    json = JSON.parse(file, :symbolize_names => true)

    mapped_result = ProductMapper.new.map_products(json[:products])

    assert mapped_result != nil
    assert mapped_result.length == 10

  end
end