module ::Boson::Args
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
end

class ::Boson::OptionCommand
  include ::Boson::Args
  alias_method :_add_default_args, :add_default_args

  def self.extract_argument(arg_name)
    arg_name.gsub(/^\*(.*?)s?$/, '\1')
  end

  def add_default_args(args, obj)
    args.each_with_index do |arg,i|
      break unless @command.args[i] && (arg_name = @command.args[i][0])
      arg_name = self.class.extract_argument(arg_name)
      if respond_to?("#{arg_name}_argument")
        args[i] = send("#{arg_name}_argument", arg)
        puts "#{arg.inspect} -> #{args[i].inspect}" if (Boson::BinRunner.options[:verbose] rescue nil)
      end
    end
    _add_default_args(args, obj)
  end
end

# This plugin interprets arguments from commands that are overridden by Boson::Scientist
# and Boson::OptionCommand.
# Arguments are intercepted by name and aliased if possible by an aliasing
# method defined in Boson::Args.
module Arguments
end