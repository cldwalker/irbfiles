module IrbFeatures
  def railsrc
    IRB_PROCS[:railrc] = lambda { load_railsrc }
  end

  def load_railsrc
    #global railsrc
    load "#{ENV['HOME']}/.railsrc" if ENV['RAILS_ENV'] && File.exists?("#{ENV['HOME']}/.railsrc")

    #local railsrc
    load File.join(ENV['PWD'], '.railsrc') if $0 == 'irb' && ENV['RAILS_ENV'] && File.exists?(File.join(ENV['PWD'], '.railsrc'))
  end

  private :load_railsrc

  #prefer to use history already shipped with irb
  def history
    require 'irb/ext/save-history'
    IRB.conf[:SAVE_HISTORY] = 1000
    IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
  end

  def aliases
    alias :x :exit
    alias :r :require
  end

  def duration
    require 'duration'
    Object.const_set(:IRB_START_TIME,Time.now)
    Kernel::at_exit { puts "\nirb session duration: #{Duration.new(Time.now - IRB_START_TIME)}" }
  end

  def irb_options
    IRB.conf[:AUTO_INDENT] = true
    require 'irb/completion'
    Object.const_set("IRB_PROCS",{}) unless Object.const_defined?(:IRB_PROCS)
    IRB.conf[:PROMPT_MODE] = :SIMPLE
    IRB.conf[:IRB_RC] = lambda do
      IRB_PROCS.each {|key, proc| proc.call }
    end
  end

  #from http://dotfiles.org/~localhost/.irbrc
  def separate_rails_history
    script_console_running = ENV.include?('RAILS_ENV') && IRB.conf[:LOAD_MODULES] && IRB.conf[:LOAD_MODULES].include?('console_with_helpers')
    rails_running = ENV.include?('RAILS_ENV') && !(IRB.conf[:LOAD_MODULES] && IRB.conf[:LOAD_MODULES].include?('console_with_helpers'))
    irb_standalone_running = !script_console_running && !rails_running
    IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history_rails" unless irb_standalone_running
  end
end