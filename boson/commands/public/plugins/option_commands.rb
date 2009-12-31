class ::Boson::Command
  def self.create(name, library)
    new (library.commands_hash[name] || {}).merge(
      {:name=>name, :lib=>library.name, :namespace=>library.namespace}.
      merge!(:global_options=>true)
    )
  end
end

# This plugin forces all commands to be wrapped by an OptionCommand.
# This is useful when using the arguments plugin on non-option commands.
module OptionCommands
end
