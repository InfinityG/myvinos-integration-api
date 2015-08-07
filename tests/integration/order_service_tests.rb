require 'minitest'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'mongo'
require 'mongo_mapper'

require './api/constants/configuration_constants'
require './api/services/order_service'
require './api/services/product_service'
require './api/models/product'
require './api/models/order'

class OrderServiceTests < MiniTest::Test

  include ConfigurationConstants::Environments

  def setup
    # setup the database connection
    MongoMapper.connection = Mongo::MongoClient.new(DEVELOPMENT[:mongo_host], DEVELOPMENT[:mongo_port])
    MongoMapper.database = DEVELOPMENT[:mongo_db]

    # load the products
    @products = ProductService.new.get_products
  end

  def test_create_order
   # TODO
  end
end