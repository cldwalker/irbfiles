module IrbFeatures
  def self.append_features(mod)
    super if defined?(IRB) && !defined?(Ripl)
  end

  class<<self
    def after_included
      irb_options
      irb_history
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
  end

  def toggle_echo
    irb_context.echo ? irb_context.echo = false : irb_context.echo = true
  end
end
