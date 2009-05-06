module Iam::Libraries
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

  def local_gem
    # gem install cldwalker-local_gem
    require 'local_gem'
    include LocalGem
  end

  # load in my ruby extensions: http://github.com/cldwalker/my_core
  # use core to load extensions: http://github.com/cldwalker/core
  def core_extensions
    LocalGem.local_require 'my_core'
    LocalGem.local_require 'core'
    Core.default_library = MyCore
    libraries = {
      :activesupport=>{:base_class=>"ActiveSupport::CoreExtensions", :base_path=>"active_support/core_ext"},
      :facets=>{:base_path=>"facets", :monkeypatch=>true},
      :nuggets=>{:base_path=>"nuggets", :monkeypatch=>true}
    }
    libraries.each do |k,v|
      Core.create_library(v)
    end

    eval %[module ::Util; end]
    #Core.verbose = true
    conf = {
      Util =>{:with=>"MyCore::Object", :only=>:class},
      Object=>{:only=>:instance},
      Dir=>{:only=>:class},
      File=>{:only=>:class},
      IO=>{:only=>:class},
    }
    conf.each do |k,v|
      Core.extends k, v
    end

    [Array, Module, Class, Hash, Regexp, String].each do |e|
      Core.extends e
    end
  end
end