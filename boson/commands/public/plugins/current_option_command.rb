# This plugin makes the current command on a commandline an OptionCommand.
# This is useful when wanting to use other plugins that depend on commands having options.
module CurrentOptionCommand
  def self.append_features(mod)
    super if Boson.const_defined?(:BinRunner)
  end

  def self.after_included
    ::Boson::Command.module_eval do
      class <<self
        alias_method :_new_attributes, :new_attributes
        def new_attributes(name, library)
          opts = _new_attributes(name, library)
          [name, opts[:alias]].include?(BinRunner.command) ? {:args=>'*'}.merge!(opts.merge!(:option_command=>true)) : opts
        end
      end
    end
  end
end
