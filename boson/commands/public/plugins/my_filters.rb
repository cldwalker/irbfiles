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

  def unalias(possible, value)
    possible.sort.grep(/^#{value}/)[0] || value
  end

  # Option filters
  def library_opt(val)
    lib_path_argument(val)
  end

  alias_method :command_opt, :command_argument
end

module MyFilters
end