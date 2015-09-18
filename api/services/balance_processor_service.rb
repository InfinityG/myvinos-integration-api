require './api/services/user_service'
require './api/services/log_service'
require './api/services/config_service'
require './api/utils/time_util'

class BalanceProcessorService

  # this will start a new thread which will process balances that were created out-of-hours
  def start
    @service_thread = Thread.new {

      config = ConfigurationService.new.get_config
      user_service = UserService.new
      log_service = LogService.new

      while true
        begin

          # check if we're in-hours
          current_hour = TimeUtil.get_current_hour_in_zone config[:time_zone]

          if current_hour > config[:trading_hours_start] || current_hour < config[:trading_hours_end]

            pending_items = user_service.get_all_with_pending_balance

            puts 'Pending balance items: ' + pending_items.length.to_s

            pending_items.each do |user|
              user_service.clear_pending_balance user
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