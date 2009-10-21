module BosonCommand
  def method_location(name)
    return nil unless (com = Boson::Command.find(name))
    if RUBY_VERSION < '1.9'
      Boson::MethodInspector.mod_store[com.library.module][:method_locations][com.name] rescue nil
    else
      com.library.module.instance_method(com.name).source_location rescue nil
    end
  end

  def show_command(name)
    return "No method location for #{name}" unless (loc = method_location(name))
    lines = IO.readlines(loc[0])
    method_lines = []
    index = loc[1] - 1
    matching_whitespace = lines[index][/^\s+/]
    while lines[index] && (lines[index] !~ /^#{matching_whitespace}end/)
      method_lines << lines[index]
      index +=1 
    end
    puts (method_lines << lines[index])
  end
end