require 'minitest'
require 'minitest/autorun'
require 'mongo'
require 'mongo_mapper'

require './api/constants/configuration_constants'
require './api/services/order_service'
require './api/models/order'

class OrderServiceTests < MiniTest::Test

  include ConfigurationConstants::Environments

  # setup the database connection
  def setup
    MongoMapper.connection = Mongo::MongoClient.new(DEVELOPMENT[:mongo_host], DEVELOPMENT[:mongo_port])
    MongoMapper.database = DEVELOPMENT[:mongo_db]
  end

  def test_create_order
    order_service = OrderService.new
    result = order_service.create_order 'vin_purchase', 100, 'ZAR', nil

    assert result.to_s != ''
  end
end