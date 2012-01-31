module BosonCommand
  # Returns a method's file and line no for a given command
  def method_location(command)
    !Boson.can_invoke?(command) && Boson::BareRunner.autoload_command(command)
    return nil unless (cmd = Boson::Command.find(command))
    if RUBY_VERSION < '1.9'
      Boson::MethodInspector.mod_store[cmd.library.module][:method_locations][cmd.name] rescue nil
    else
      cmd.library.module.instance_method(cmd.name).source_location rescue nil
    end
  end

  # @render_options :method=>'puts'
  # Returns the method body of a command using method_location.
  def show_command(command)
    unless (loc = method_location(command))
      if (cmd= Boson::Command.find(command)) && cmd.library && cmd.library.class_commands &&
        (aliasee = cmd.library.class_commands[cmd.name])
        return "No command found since it's aliased to #{aliasee}"
      else
        return "No method location for #{command}"
      end
    end

    return "File '#{loc[0]}' doesn't exist" unless File.exists? loc[0]
    lines = IO.readlines(loc[0])
    method_lines = []
    index = loc[1] - 1
    matching_whitespace = lines[index][/^\s+/]
    while lines[index] && (lines[index] !~ /^#{matching_whitespace}end/)
      method_lines << lines[index]
      index +=1
    end
    (method_lines << lines[index]).join("")
  end
end
