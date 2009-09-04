module BosonLib
  def help(name)
    return "Command not loaded" unless (command = Boson.command(name.to_s) || Boson.command(name.to_s, :alias))
    return "Library for #{command_obj.name} not found" unless lib = Boson.library(command.lib)
    return "Can only determine FileLibrary methods for now" unless lib.is_a?(Boson::FileLibrary)
    lib_string = File.read(Boson::Library.library_file(lib.name))
    if match = /def\s+#{name}\s*\(?\s*([^\)]+)\s*\)?\s*$/.match(lib_string)
      "#{name} "+ match.to_a[1].split(/\s*,\s*/).map {|e| "[#{e}]"}.join(' ')
    else
      "Command not found in file"
    end
  end

  def edit_library(name)
    file = Boson::Library.library_file(name.to_s)
    system("vim", file)
  end

  def undetected_methods(priv=false)
    public_undetected = metaclass.instance_methods - (Kernel.instance_methods + Object.instance_methods(false) + MyCore::Object::InstanceMethods.instance_methods +
      Boson.commands.map {|e| [e.name, e.alias] }.flatten.compact)
    public_undetected -= IRB::ExtendCommandBundle.instance_eval("@ALIASES").map {|e| e[0].to_s} if Object.const_defined?(:IRB)
    priv ? (public_undetected + metaclass.private_instance_methods - (Kernel.private_instance_methods + Object.private_instance_methods)) : public_undetected
  end
end