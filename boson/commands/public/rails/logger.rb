# logger cmds from http://weblog.jamisbuck.org/2007/1/31/more-on-watching-activerecord
module LoggerLib
  def self.append_features(mod)
    super if ENV['RAILS_ENV'] || defined? Rails
  end

  def self.after_included
    IRB_PROCS[:setup_logger] = method(:setup_logger) if Object.const_defined?(:IRB_PROCS)
  end

  def self.setup_logger(*args)
    Object.const_set(:RAILS_DEFAULT_LOGGER, ::Logger.new(STDOUT)) unless Object.const_defined?(:RAILS_DEFAULT_LOGGER)
  end

  # Shows log on screen
  def show_log
    change_log(STDOUT)
  end

  # Stops showing log
  def hide_log
    change_log(nil)
  end

  private
  # as needed
  #def logger.flush; end unless logger.respond_to?(:flush)
  #ActionController::Base.logger = logger
  def change_log(stream, colorize=true)
    ActiveRecord::Base.logger = ::Logger.new(stream)
    ActiveRecord::Base.clear_all_connections!
    ActiveRecord::Base.colorize_logging = colorize
  end
end
