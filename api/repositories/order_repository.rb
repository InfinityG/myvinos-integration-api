require 'mongo_mapper'
require 'bson'
require './api/models/order'
require './api/models/transaction'
require './api/models/product'

class OrderRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models

  def create_vin_purchase_order(checkout_id, amount, currency, products)

    type = 'vin_purchase'

    # create transaction record with checkout id
    transaction = Transaction.new(:type => 'vin_purchase',
                                  :checkout_id => checkout_id,
                                  :amount => amount,
                                  :currency => currency,
                                  :status => 'pending')

    begin
      # create order record with transaction and products
      result = Order.create(:type => type, :transaction => transaction, :products => products)
    rescue Error => e
      err = e.message
    end
  end

  def update_vin_purchase_order_status(status)

  end

end