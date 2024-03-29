require 'active_support/core_ext/time'

module TimeUtil

  def self.get_current_hour_in_zone(zone)
    t = Time.now
    t.in_time_zone(zone).hour
    end

  def self.get_current_day_in_zone(zone)
    t = Time.now
    t.in_time_zone(zone).wday
  end

end