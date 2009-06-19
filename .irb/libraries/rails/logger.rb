# http://weblog.jamisbuck.org/2007/1/31/more-on-watching-activerecord

module Logger
  def self.included(mod)
    require 'logger'
    Object.const_set(:RAILS_DEFAULT_LOGGER, ::Logger.new(STDOUT)) unless Object.const_defined?(:RAILS_DEFAULT_LOGGER)
  end

  def change_log(stream, colorize=true)
    ActiveRecord::Base.logger = ::Logger.new(stream)
    ActiveRecord::Base.clear_active_connections!
    ActiveRecord::Base.colorize_logging = colorize
  end

  def show_log
    change_log(STDOUT)
  end

  def hide_log
    change_log(nil)
  end
end