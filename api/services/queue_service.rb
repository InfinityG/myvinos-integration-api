require './api/repositories/queue_repository'

class QueueService

  def initialize(queue_repository = QueueRepository)
    @queue_repository = queue_repository.new
  end

  def add_item_to_queue(order_id, checkout_id)
    @queue_repository.create_queue_item order_id.to_s, checkout_id
  end

  def get_pending_items
    @queue_repository.get_pending_queue_items
  end

  def update_queue_item(id, status)
    @queue_repository.update_queue_item id, status
    end

  def delete_queue_item(id)
    @queue_repository.delete_queue_item id
  end
end