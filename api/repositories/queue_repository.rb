require 'mongo_mapper'
require 'bson'
require './api/models/queue_item'

class QueueRepository
  include Mongo
  include MongoMapper
  include BSON
  include MyVinos::Models

  def create_queue_item(order_id, checkout_id)
    QueueItem.create(:order_id => order_id.to_s, :checkout_id => checkout_id,
                     :status => 'pending')
  end

  def get_pending_queue_items
    QueueItem.all(:status => 'pending', :order => :created_at.asc)
  end

  def update_queue_item(queue_item_id, status)
    item = QueueItem.find queue_item_id.to_s

    if item != nil
      item.status = status
      item.save
    else
      raise "QueueItem with id #{queue_item_id} not found!"
    end
  end
end