module IrbFeatures
  def self.append_features(mod)
    super if Object.const_defined?(:IRB)
  end

  class<<self
    def after_included
      irb_options
      railsrc
      irb_history
      irb_prompts
    end

    def irb_history
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

    def railsrc
      IRB_PROCS[:railsrc] = lambda {|e| load_railsrc }
    end

    def load_railsrc
      #local railsrc
      load File.join(ENV['PWD'], '.railsrc') if (ENV['RAILS_ENV'] || defined?(Rails)) && File.exists?(File.join(ENV['PWD'], '.railsrc'))
    end
  end

  def toggle_echo
    irb_context.echo ? irb_context.echo = false : irb_context.echo = true
  end
end
