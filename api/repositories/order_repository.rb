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

  def get_orders(user_id)
    Order.where(:user_id => user_id).all
    end

  def get_non_abandoned_orders(user_id)
    Order.where(:user_id => user_id, 'transaction.status' => {:$ne => 'abandoned'}).all
  end

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

  def create_vin_redemption_order(user, amount, currency, products, location, notes)

    type = 'vin_redemption'

    transaction = Transaction.new(:type => type,
                                  :amount => amount,
                                  :currency => currency,
                                  :status => 'pending')

    delivery = Delivery.new(:status => 'pending',
                            :external_id => '',
                            :time_estimate => '',
                            :distance_estimate => '',
                            :address => location[:address],
                            :coordinates => location[:coordinates],
                            :mobile_number => user.mobile_number,
                            :notes => notes)

    # create order record with transaction and products
    Order.create(:user_id => user.id.to_s,
                 :external_order_id => '',
                 :type => type,
                 :status => 'pending',
                 :transaction => transaction,
                 :delivery => delivery,
                 :products => products)
  end

  def update_order(order)
    order.save
  end

  def update_order_status(order_id, status)
    order = Order.find(order_id.to_s)

    if order != nil
      order.status = status
      order.save
    else
      raise "Order with id #{order_id} not found!"
    end

    order
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

  def update_order_delivery_status(order_id, status)
    order = Order.find(order_id.to_s)

    if order != nil
      order.delivery.status = status
      order.save
    else
      raise "Order with id #{order_id} not found!"
    end

    order
  end

end