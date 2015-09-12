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
            status_result = order_service.get_checkout_status(item.checkout_id)
            puts "Item status #{item.checkout_id}: #{status_result}"

            # failure
            if status_result[:status] == 'failure'
              queue_service.update_queue_item item.id, 'failure'
              order_service.update_order_transaction item.order_id, nil, 'failure'
            end

            # success
            if status_result[:status] == 'success'
              queue_service.update_queue_item item.id, 'success'
              order = order_service.update_order_transaction item.order_id, status_result[:transaction_id], 'success'

              # credit the user's VIN balance - apply the conversion from ZAR to VIN
              amount = RateUtil.convert_fiat_to_vin(order.transaction.amount.to_i)
              user_service.update_balance(order.user_id, amount)
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