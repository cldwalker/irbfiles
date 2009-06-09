#mostly from http://github.com/stephencelis/dotfiles/blob/master/railsrc
#which in turn is probably from defunkt

module Logger
  def self.included(mod)
    require 'logger'
    Object.const_set(:RAILS_DEFAULT_LOGGER, ::Logger.new(STDOUT)) unless Object.const_defined?(:RAILS_DEFAULT_LOGGER)
  end

  def change_log(stream)
    ActiveRecord::Base.logger = ::Logger.new(stream)
    ActiveRecord::Base.clear_active_connections!
  end

  def show_log
    change_log(STDOUT)
  end

  def hide_log
    change_log(nil)
  end
end