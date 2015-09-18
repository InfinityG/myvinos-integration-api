require './api/services/queue_service'
require './api/services/order_service'
require './api/services/user_service'
require './api/services/log_service'
require './api/utils/rate_util'
require 'time'

class QueueProcessorService

  # this will start a new thread which will periodically retrieve pending
  # items from the DB and attempt to process them
  def start
    @service_thread = Thread.new {

      queue_service = QueueService.new
      order_service = OrderService.build
      user_service = UserService.new
      log_service = LogService.new

      while true
        begin
          pending_items = queue_service.get_pending_items
          puts 'Pending checkout items: ' + pending_items.length.to_s

          pending_items.each do |item|
            status_result = order_service.get_checkout_status(item.checkout_id, item.created_at)
            puts "Item status #{item.checkout_id}: #{status_result}"

            # abandoned
            if status_result[:status] == 'abandoned'
              order_service.update_order_transaction item.order_id, nil, 'abandoned'
              queue_service.delete_queue_item item.id
            end

            # failure
            if status_result[:status] == 'failure'
              order_service.update_order_transaction item.order_id, nil, 'failure'
              queue_service.delete_queue_item item.id
            end

            # success
            if status_result[:status] == 'success'
              order = order_service.update_order_transaction item.order_id, status_result[:transaction_id], 'success'

              # credit the user's VIN balance - apply the conversion from ZAR to VIN
              amount = order.transaction.amount.to_i
              user_service.update_balance(order.user_id, amount)

              queue_service.delete_queue_item item.id
            end

            sleep 1.seconds
          end
        rescue Exception => e
          log_service.log_error(e.message.to_json)
        end

        sleep 5.seconds
      end
    }
  end
end