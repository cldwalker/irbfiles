module Duration
  def self.included(mod)
    require 'duration'
    Object.const_set(:REPL_START_TIME,Time.now)
    Kernel::at_exit { puts "\nsession duration: #{::Duration.new(Time.now - REPL_START_TIME)}" }
  end
end