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
    unalias Boson::Index.commands.map {|e| e.name }, val
  end

  def unalias(possible, value)
    possible.sort.grep(/^#{value}/)[0] || value
  end

  # Option filters
  def library_opt(val)
    lib_path_argument(val)
  end
end

module MyFilters
end