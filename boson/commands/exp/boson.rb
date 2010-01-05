module BosonLib
  # @render_options :change_fields=>['arguments', 'commands']
  # @options :count=>:boolean, :transform=>true
  # Lists arguments from all known commands. Depends on option_command_filters plugin.
  def arguments(options={})
    Boson::Index.read
    hash = Boson::Index.commands.inject({}) {|t,com|
      (com.args || []).each {|arg|
        arg_name = options[:transform] ? Boson::OptionCommand.extract_argument(arg[0].to_s) : arg[0]
        (t[arg_name] ||= []) << com.name
      }
      t
    }
    count_or_inspect(hash, options)
  end

  # @render_options :change_fields=>['name', 'count']
  # @options :type=>:boolean, :count=>true, [:skip_booleans, :S]=>true
  # @desc Lists option stats from all known commands. Doesn't include boolean options
  # if listing option names.
  def options(options={})
    Boson::Index.read
    hash = Boson::Index.commands.select {|e| e.options}.inject({}) {|a,com|
      (options[:type] ? com.option_parser.types : com.option_parser.names).each {|e|
        # skip boolean options
        next if options[:skip_booleans] && !options[:type] &&
          (com.option_parser.option_type(com.option_parser.dasherize(e)) == :boolean)
        (a[e] ||= []) << com.name
      }
      a
    }
    count_or_inspect(hash, options)
  end

  def count_or_inspect(hash, options)
    hash.inject({}) {|h,(k,v)|
      h[k] = options[:count] ? v.size : v.inspect
      h
    }
  end

  # Used as a pipe option to pipe to any command
  def post_command(arg, command)
    Boson.full_invoke(command, [arg])
  end

  # @options :all=>:boolean, :verbose=>true, :reset=>:boolean
  # Updates/resets index of libraries and commands
  def index(options={})
    Boson::Index.indexes {|index|
      File.unlink(index.marshal_file) if options[:reset] && File.exists?(index.marshal_file)
      index.update(options)
    }
  end

  # Downloads a url and saves to a local boson directory
  def download(url)
    filename = determine_download_name(url)
    File.open(filename, 'w') { |f| f.write get(url) }
    filename
  end

  # Tells you what methods in current binding aren't boson commands.
  def undetected_methods(priv=false)
    public_undetected = metaclass.instance_methods - (Kernel.instance_methods + Object.instance_methods(false) + MyCore::Object::InstanceMethods.instance_methods +
      Boson.commands.map {|e| [e.name, e.alias] }.flatten.compact)
    public_undetected -= IRB::ExtendCommandBundle.instance_eval("@ALIASES").map {|e| e[0].to_s} if Object.const_defined?(:IRB)
    priv ? (public_undetected + metaclass.private_instance_methods - (Kernel.private_instance_methods + Object.private_instance_methods)) : public_undetected
  end

  private  
  def determine_download_name(url)
    FileUtils.mkdir_p(File.join(Boson.repo.dir,'downloads'))
    basename = strip_name_from_url(url) || url.sub(/^[a-z]+:\/\//,'').tr('/','-')
    filename = File.join(Boson.repo.dir, 'downloads', basename)
    filename += "-#{Time.now.strftime("%m_%d_%y_%H_%M_%S")}" if File.exists?(filename)
    filename
  end
end