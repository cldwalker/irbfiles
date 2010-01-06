class ::Boson::Command
  class <<self
    alias_method :_new_options, :new_options
    def new_options(name, library)
      _new_options(name, library).merge!(:global_options=>true)
    end
  end
end

# This plugin forces all commands to be wrapped by an OptionCommand.
# This is useful when wanting to use the option_command_filters plugin on non-option commands.
module OptionCommands
end
