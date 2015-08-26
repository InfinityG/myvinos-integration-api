require 'mongo_mapper'
require 'bson'
require './api/models/order'
require './api/models/transaction'
require './api/models/product'
require './api/models/delivery'

class OrderRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models

  def create_vin_purchase_order(user_id, checkout_id, amount, currency, products)

    type = 'vin_purchase'

    # create transaction record with checkout id
    transaction = Transaction.new(:type => type,
                                  :checkout_id => checkout_id,
                                  :external_transaction_id => '',
                                  :amount => amount,
                                  :currency => currency,
                                  :status => 'pending')

    # create order record with transaction and products
    Order.create(:user_id => user_id, :type => type, :transaction => transaction, :products => products)
  end

  def create_vin_redemption_order(user_id, third_party_order_id, amount, currency, products, location)

    type = 'vin_redemption'

    transaction = Transaction.new(:type => type,
                                  :amount => amount,
                                  :currency => currency,
                                  :status => 'complete')

    delivery = Delivery.new(:status => 'pending',
                            :address => location[:address],
                            :coordinates => location[:coordinates])

    # create order record with transaction and products
    Order.create(:user_id => user_id, :external_order_id => third_party_order_id,
                 :type => type, :transaction => transaction, :delivery => delivery, :products => products)
  end

  def update_order_transaction_status(order_id, external_transaction_id, status)
    order = Order.find(order_id.to_s)

    if order != nil
      order.transaction.status = status
      order.transaction.external_transaction_id = external_transaction_id
      order.save
    else
      raise "Order with id #{order_id} not found!"
    end

    order
  end

end