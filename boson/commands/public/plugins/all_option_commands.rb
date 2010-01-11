# This plugin forces all commands to be wrapped by an OptionCommand.
# This is useful when wanting to use the option_command_filters plugin on non-option commands.
# This plugins only affects commands from commandline.
module AllOptionCommands
  def self.append_features(mod)
    super if Boson.const_defined?(:BinRunner)
  end

  def self.after_included
    ::Boson::Command.module_eval do
      class <<self
        alias_method :_new_options, :new_options
        def new_options(name, library)
          opts = _new_options(name, library)
          !opts.key?(:render_options) && !opts.key?(:options) ?
            opts.merge!(:global_options=>true) : opts
        end
      end
    end
  end
end
