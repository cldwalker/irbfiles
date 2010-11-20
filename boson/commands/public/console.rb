module Console
  def self.included(mod)
    require 'readline'
  end

  # Reset console process
  def console_reset
    exec($0)
  end

  # Eval in console's binding
  def console_eval(string)
    string.split("\n").each {|e| Readline::HISTORY << e }
    eval(string)
  end

  # List of current variables
  def current_variables
    console_eval "local_variables - (self.methods + self.private_methods)"
  end
end
