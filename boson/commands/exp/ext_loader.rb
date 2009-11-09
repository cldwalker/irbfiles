module ExtLoader
  # Loads an extension library i.e. libraries under core/*.
  def load_extension(name)
    return "Extension not found" unless (lib = Boson.library(name))
    basename = File.basename(name)
    eval %[module Boson::Commands::NewCore ; end]
    new_mod = Boson::Util.camelize "boson/commands/new_core/#{basename}"
    eval ExtLoader.generate_extension_module(new_mod, lib.module)
    if (top_level_mod = Boson::Util.any_const_get(basename.capitalize)) &&
      (ext_mod = Boson::Util.any_const_get(new_mod))
      top_level_mod.send :include, ext_mod
    else
      'Class/Module to extend not found'
    end
  end

  class <<self
    def generate_extension_module(new_mod, old_mod)
      %[module #{new_mod}\n  include #{old_mod}\n] +
        old_mod.instance_methods.map {|e| "def #{e}(*args); super(self, *args); end" }.join("\n") +
      "\nend"
    end
  end
end