module Duration
  def self.included(mod)
    require 'duration'
    Object.const_set(:IRB_START_TIME,Time.now)
    Kernel::at_exit { puts "\nirb session duration: #{::Duration.new(Time.now - IRB_START_TIME)}" }
  end
end