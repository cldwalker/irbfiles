# logger cmds from http://weblog.jamisbuck.org/2007/1/31/more-on-watching-activerecord

module Logger
  def self.append_features(mod)
    super if ENV['RAILS_ENV']
  end

  def self.included(mod)
    IRB_PROCS[:setup_rails] = method(:setup_rails) if Object.const_defined?(:IRB_PROCS) && ENV['RAILS_ENV']
  end

  def self.setup_rails(*args)
    Object.const_set(:RAILS_DEFAULT_LOGGER, ::Logger.new(STDOUT)) unless Object.const_defined?(:RAILS_DEFAULT_LOGGER)
    Alias.create :file=>"~/.alias/rails.yml"
    require 'console_update' #gem install cldwalker-console_update
    ConsoleUpdate.enable_named_scope
  end

  def show_log
    change_log(STDOUT)
  end

  def hide_log
    change_log(nil)
  end

  private
  #intermittently works if AB.logger.close
  def change_log(stream, colorize=true)
    ActiveRecord::Base.logger = ::Logger.new(stream)
    ActiveRecord::Base.clear_active_connections!
    ActiveRecord::Base.colorize_logging = colorize
  end
end