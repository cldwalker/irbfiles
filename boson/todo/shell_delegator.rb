#from http://bangmyhead.com/2008/5/4/interactive-ruby-console-configuration-file-irbc
# and http://woss.name/2006/07/12/using-the-shell-within-irb/

require 'shell'

# Override the command processor widget for inserting system commands so
# that it behaves more like path-processing: earlier commands take precedence.
require 'shell/command-processor'
module FixAddDelegateCommandToShell
  def self.extended(obj)
    class << obj
      alias_method :add_delegate_command_to_shell_override, :add_delegate_command_to_shell unless method_defined?(:add_delegate_command_to_shell_override)
      alias_method :add_delegate_command_to_shell, :add_delegate_command_to_shell_no_override
    end
  end

  def add_delegate_command_to_shell_no_override(id)
    id = id.intern if id.kind_of?(String)
    name = id.id2name
    if Shell.method_defined?(id) or Shell::Filter.method_defined?(id)
      Shell.notify "warn: Not overriding existing definition of Shell##{name}."
    else
      add_delegate_command_to_shell_override(id)
    end
  end
end
Shell::CommandProcessor.extend(FixAddDelegateCommandToShell)

# Allow Shell system commands to take :symbols too, to save a little typing.
require 'shell/system-command'
class Shell
  class SystemCommand
    alias_method :initialize_orig, :initialize
    def initialize(sh, command, *opts)
      opts.collect! {|opt| opt.to_s }
      initialize_orig sh, command, *opts
    end
  end
end

# Provide me with a shell inside IRB to save quitting and restarting, or
# finding that other terminal window.
def shell
  unless $shell
    Shell.install_system_commands '' # no prefix
    $shell = Shell.new
  end
  $shell
end
