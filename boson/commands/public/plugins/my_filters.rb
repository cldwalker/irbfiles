module ::Boson::OptionCommand::Filters
  # Argument filters
  def url_argument(val)
    val[/:\/\//] ? val : "http://#{val}"
  end

  def klass_argument(val)
    val = unalias(Object.constants, val)
    ::Boson::Util.any_const_get(val)
  end
  alias_method :mod_argument, :klass_argument

  def library_argument(val)
    Boson::Index.read
    unalias Boson::Index.libraries.map {|e| e.name }, val
  end

  def lib_path_argument(val)
    Boson::Index.read
    lib_hash = Boson::Index.libraries.map {|e| e.name}.inject({}) {|a,e|
      a[File.basename(e)] = e; a }
    val = unalias lib_hash.keys, val
    lib_hash[val] || val
  end

  def command_argument(val)
    Boson::Index.read
    return val if Boson::Index.find_command(val)
    unalias Boson::Index.commands.map {|e| e.name }, val
  end

  def command_obj_argument(val)
    command = command_argument(val)
    !Boson.can_invoke?(command) && Boson::Runner.autoload_command(command)
    command
  end

  def user_repo_argument(val)
    val[/^([^\/])+-/] ? val.sub('-', '/') : val
  end

  # from meth_missing plugin
  def underscore_search(input, list)
    if input.include?("_")
      index = 0
      input.split('_').inject(list) {|new_list,e|
        new_list = new_list.select {|f| f.split(/_+/)[index] =~ /^#{Regexp.escape(e)}/ };
        index +=1; new_list
      }
    else
      list.grep(/^#{Regexp.escape(input)}/)
    end
  end

  def unalias(possible, value)
    underscore_search(value, possible.sort)[0] || value
  end

  # Option filters
  def library_opt(val)
    lib_path_argument(val)
  end

  alias_method :command_opt, :command_argument
end

module MyFilters
end