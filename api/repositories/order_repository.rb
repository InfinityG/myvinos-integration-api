require 'mongo_mapper'
require 'bson'
require './api/models/order'
require './api/models/transaction'
require './api/models/product'
require './api/models/delivery'
require './api/constants/api_constants'

class OrderRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models
  include ApiConstants

  def get_orders(user_id)
    Order.where(:user_id => user_id).all
  end

  def get_non_abandoned_orders(user_id)
    Order.where(:user_id => user_id, 'transaction.status' => {:$ne => PAYMENT_STATUS_ABANDONED}).all
  end

  def create_vin_purchase_order(user_id, checkout_id, amount, currency, products)

    type = VIN_PURCHASE_TYPE

    # create transaction record with checkout id
    transaction = Transaction.new(:type => type,
                                  :checkout_id => checkout_id,
                                  :external_transaction_id => '',
                                  :amount => amount,
                                  :currency => currency,
                                  :status => PAYMENT_STATUS_PENDING)

    # create order record with transaction and products
    Order.create(:user_id => user_id, :type => type, :transaction => transaction, :products => products)
  end

  def create_vin_credit_order(user_id, amount, currency, products, memo)

    type = VIN_CREDIT_TYPE

    # create transaction record with checkout id
    transaction = Transaction.new(:type => type,
                                  :amount => amount,
                                  :currency => currency,
                                  :status => PAYMENT_STATUS_COMPLETE,
                                  :memo => memo)

    # create order record with transaction and products
    Order.create(:user_id => user_id, :type => type, :transaction => transaction, :products => products)
  end

  def create_mem_purchase_order(user_id, checkout_id, transaction_id, amount, currency, products, status, memo)

    type = MEMBERSHIP_PURCHASE_TYPE

    # create transaction record
    transaction = Transaction.new(:type => type,
                                  :checkout_id => checkout_id,
                                  :external_transaction_id => transaction_id != nil ? transaction_id : '',
                                  :amount => amount,
                                  :currency => currency,
                                  :status => status,
                                  :memo => memo)

    # create order record with transaction and products
    Order.create(:user_id => user_id, :type => type, :transaction => transaction, :products => products)
  end

  def create_vin_topup_order(user_id, checkout_id, transaction_id, amount, currency, status, memo)

    type = VIN_TOP_UP_TYPE

    # create transaction record
    transaction = Transaction.new(:type => type,
                                  :checkout_id => checkout_id,
                                  :external_transaction_id => transaction_id != nil ? transaction_id : '',
                                  :amount => amount,
                                  :currency => currency,
                                  :status => status,
                                  :memo => memo)

    # create order record with transaction and products
    Order.create(:user_id => user_id, :type => type, :transaction => transaction, :products => [])
  end

  def create_vin_redemption_order(user, amount, currency, products, location, notes)

    type = VIN_REDEMPTION_TYPE

    transaction = Transaction.new(:type => type,
                                  :amount => amount,
                                  :currency => currency,
                                  :status => PAYMENT_STATUS_PENDING)

    delivery = Delivery.new(:status => PAYMENT_STATUS_PENDING,
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
                 :status => PAYMENT_STATUS_PENDING,
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