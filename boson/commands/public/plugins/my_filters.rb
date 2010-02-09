# My filters for option_command_filters plugin
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

  # an extra argument is added when used with bl
  def library_obj_argument(val)
    val = lib_path_argument(val)
    ::Boson.invoke :load_library, val
    val
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

  def unalias(possible, value)
    ::Boson::Util.underscore_search(value, possible.sort, true) || value
  end

  # Option filters
  def library_option(val)
    lib_path_argument(val)
  end

  alias_method :command_option, :command_argument
end