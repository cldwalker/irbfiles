module IrbFeatures
  def history
    IRB.conf[:SAVE_HISTORY] = 1000
    IRB.conf[:EVAL_HISTORY] = 200
  end

  def irb_options
    IRB.conf[:AUTO_INDENT] = true
    IRB.conf[:SINGLE_IRB] = true
    IRB.conf[:PROMPT_MODE] = :SIMPLE
    Object.const_set("IRB_PROCS",{}) unless Object.const_defined?(:IRB_PROCS)
    IRB.conf[:IRB_RC] = lambda do |e|
      IRB_PROCS.each {|key, proc| proc.call(e); IRB_PROCS.delete(key)}
    end
  end

  def irb_verbosity_toggle
    irb_context.echo ? irb_context.echo = false : irb_context.echo = true
  end

  #from http://dotfiles.org/~localhost/.irbrc
  def separate_rails_history
    IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history_rails" if (ENV['RAILS_ENV'] && IRB.conf[:LOAD_MODULES] && 
      IRB.conf[:LOAD_MODULES].include?('console_with_helpers'))
  end

  def railsrc
    IRB_PROCS[:railsrc] = lambda { load_railsrc }
  end

  def irb_prompts
    dirname = File.basename(Dir.pwd)
    IRB.conf[:PROMPT][:DIR] = {
      :PROMPT_I => "#{dirname}> ",
      :PROMPT_N => "#{dirname}> ",
      :PROMPT_S => "#{dirname}* ",
      :PROMPT_C => "#{dirname}? ",
      :RETURN => "=> %s\n"
    }
  end

  private
  def load_railsrc
    #global railsrc
    load "#{ENV['HOME']}/.railsrc" if ENV['RAILS_ENV'] && File.exists?("#{ENV['HOME']}/.railsrc")

    #local railsrc
    load File.join(ENV['PWD'], '.railsrc') if ENV['RAILS_ENV'] && File.exists?(File.join(ENV['PWD'], '.railsrc'))
  end
end