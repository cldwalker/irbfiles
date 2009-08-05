module Console
  if Object.const_defined?(:IRB)
    def console_reset
      at_exit { exec($0) }
      IRB::HistorySavingAbility.create_finalizer.call
      throw :IRB_EXIT, 0
    end

    def console_eval(string)
      string.split("\n").each {|e| Readline::HISTORY << e }
      IRB.CurrentContext.workspace.evaluate(self, string)
    end
  else
    def console_reset
      exec($0)
    end

    def console_eval(string)
      string.split("\n").each {|e| Readline::HISTORY << e }
      eval(string)
    end
  end

  def current_variables
    console_eval "local_variables - (self.methods + self.private_methods)"
  end
end