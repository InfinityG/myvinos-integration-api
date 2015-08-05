require './api/services/queue_service'
require './api/services/order_service'

class QueueProcessorService

  # this will start a new thread which will periodically retrieve pending
  # items from the DB and attempt to process them
  def start
    @service_thread = Thread.new {

      queue_service = QueueService.new
      order_service = OrderService.new

      while true
        begin
          pending_items = queue_service.get_pending_items

          pending_items.each do |queue_item|
            checkout_id = queue_item.checkout_id
            queue_service.update_queue_item queue_item.id, 'complete' if order_service.get_checkout_status(checkout_id)
          end
        rescue Exception => e
          LOGGER.error "Error processing queue item! || Error: #{e}"
        end

        sleep 5.0
      end
    }
  end
end