module BosonCommand
  # Returns a method's file and line no for a given command
  def method_location(name)
    !Boson.can_invoke?(name) && Boson::Index.read && (lib = Boson::Index.find_library(name)) &&
      Boson::Manager.load(lib, :verbose=>true)
    return nil unless (com = Boson::Command.find(name))
    if RUBY_VERSION < '1.9'
      Boson::MethodInspector.mod_store[com.library.module][:method_locations][com.name] rescue nil
    else
      com.library.module.instance_method(com.name).source_location rescue nil
    end
  end

  # @render_options :method=>'puts'
  # Returns the method body of a command using method_location.
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
    (method_lines << lines[index]).join("")
  end
end
