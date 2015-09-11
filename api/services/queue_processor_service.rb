require './api/services/queue_service'
require './api/services/order_service'
require './api/services/user_service'
require './api/services/log_service'
require './api/utils/rate_util'

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
          puts 'Pending items: ' + pending_items.length.to_s

          pending_items.each do |item|
            status = order_service.get_checkout_status(item.checkout_id)
            puts "Item status #{item.checkout_id}: #{status}"

            unless status[:success]
              # flag the queue item as error
              queue_service.update_queue_item item.id, 'error'

              # flag the transaction as error
              order_service.update_order_transaction item.order_id, nil, 'error'

              next
            end

            # flag the queue item as complete
            queue_service.update_queue_item item.id, 'complete'

            # flag the transaction as complete
            order = order_service.update_order_transaction item.order_id, status[:transaction_id], 'complete'

            # credit the user's VIN balance - apply the conversion from ZAR to VIN
            amount = RateUtil.convert_fiat_to_vin(order.transaction.amount.to_i)
            user_service.update_balance(order.user_id, amount)

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