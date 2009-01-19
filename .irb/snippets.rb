IRB_METHOD_PREFIX = "irb_lib_"

#loads pp, irb/completion, convenience methods for ri and object inspection (:ri, :po, :poc)
# another color possibility: http://github.com/rkh/dotfiles/tree/master/.config/irb/color.rb
def irb_lib_wirble
  require 'wirble'
  Wirble.init :skip_history=>true
  Wirble.colorize
end

def irb_lib_utility_belt
  gem "utility_belt"
  require 'utility_belt/equipper'
  UtilityBelt.equip(:string_to_proc, :with, :not, :pipe, :language_greps, :irb_verbosity_control,
    :clipboard, :hash_math, :interactive_editor, :command_history)
end

def irb_lib_railsrc
  #global railsrc
  load "#{ENV['HOME']}/.railsrc" if ENV['RAILS_ENV'] && File.exists?("#{ENV['HOME']}/.railsrc")

  #local railsrc
  load File.join(ENV['PWD'], '.railsrc') if $0 == 'irb' && ENV['RAILS_ENV']
end

#prefer to use history already shipped with irb
def irb_lib_history
  require 'irb/ext/save-history'
  IRB.conf[:SAVE_HISTORY] = 1000
  IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
end

def irb_lib_aliases
  alias :x :exit
  alias :r :require
  alias :iload :load_irb_lib
end

def irb_lib_misc_gems
  %w{what_methods andand method_lister backports irb-history}.each {|e| require e }
end

def irb_lib_duration
  require 'duration'
  Object.const_set(:IRB_START_TIME,Time.now)
  at_exit { puts "\nirb session duration: #{Duration.new(Time.now - IRB_START_TIME)}" }
end

def irb_lib_irb_options
  IRB.conf[:AUTO_INDENT] = true
end

#from http://dotfiles.org/~localhost/.irbrc
def irb_lib_separate_rails_history
  script_console_running = ENV.include?('RAILS_ENV') && IRB.conf[:LOAD_MODULES] && IRB.conf[:LOAD_MODULES].include?('console_with_helpers')
  rails_running = ENV.include?('RAILS_ENV') && !(IRB.conf[:LOAD_MODULES] && IRB.conf[:LOAD_MODULES].include?('console_with_helpers'))
  irb_standalone_running = !script_console_running && !rails_running
  IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history_rails" unless irb_standalone_running
end
