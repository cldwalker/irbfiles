module Console
  def self.included(mod)
    require 'readline'
  end

  if Object.const_defined?(:IRB)
    # Reset console process
    def console_reset
      at_exit { exec($0) }
      IRB::HistorySavingAbility.create_finalizer.call
      throw :IRB_EXIT, 0
    end

    # Eval in console's binding
    def console_eval(string)
      string.split("\n").each {|e| Readline::HISTORY << e }
      IRB.CurrentContext.workspace.evaluate(self, string)
    end
  else
    # Reset console process
    def console_reset
      exec($0)
    end

    # Eval in console's binding
    def console_eval(string)
      string.split("\n").each {|e| Readline::HISTORY << e }
      eval(string)
    end
  end

  # List of current variables
  def current_variables
    console_eval "local_variables - (self.methods + self.private_methods)"
  end
end