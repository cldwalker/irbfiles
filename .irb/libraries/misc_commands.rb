module MiscCommands
  #Reloads a file just as you would require it.
  def reload(filename)
    filename += '.rb' unless filename[/\.rb$/]
    $".delete(filename)
    require(filename)
  end

  def backtick(cmd,*args)
    ::IO.popen('-') {|f| f ? f.read : exec(cmd,*args)}
  end

  # A more versatile version of Module#const_get.
  # Retrieves constant for given string, even if it's nested under classes.
  def any_const_get(name)
    klass = ::Object
    name.split('::').each {|e|
      klass = klass.const_get(e)
    }
    klass
  rescue
    nil
  end

  def undetected_methods(priv=false)
    public_undetected = metaclass.instance_methods - (Kernel.instance_methods + Object.instance_methods + Iam.commands.map {|e| [e[:name], e[:alias]] }.flatten.compact +
      IRB::ExtendCommandBundle.instance_eval("@ALIASES").map {|e| e[0].to_s} + Iam::Libraries.instance_methods)
    priv ? (public_undetected + metaclass.private_instance_methods - (Kernel.private_instance_methods + Object.private_instance_methods)) : public_undetected
  end
end