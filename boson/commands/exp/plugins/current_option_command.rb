# This plugin makes the current command on a commandline an OptionCommand.
# This is useful when wanting to use other plugins that depend on commands having options.
module CurrentOptionCommand
  def self.append_features(mod)
    super if Boson.const_defined?(:BinRunner)
  end

  def self.after_included

    ::Boson::Command.module_eval do
      def self.create(name, library)
        obj = new(new_attributes(name, library))
        if [obj.name, obj.alias].include?(BinRunner.command)
          obj.make_option_command(library)
        end
        obj
      end
    end

  end
end
