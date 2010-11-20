module BosonLib
  # @render_options :change_fields=>['name', 'commands']
  # @options :type=>:boolean, [:skip_booleans, :S]=>true, :global_options=>:boolean, :use_parser=>:boolean
  # @desc Lists option stats from all known commands. Doesn't include boolean options
  # if listing option names.
  def opts(options={})
    Boson::Index.read
    hash = Boson::Index.commands.select {|e| e.option_command? }.inject({}) {|a,com|
      opt_parser = options[:global_options] ?
        Boson::Scientist.option_command(com).option_parser : com.option_parser
      names_or_types = options[:use_parser] ?
        (options[:type] ? opt_parser.types : opt_parser.names) :
        (options[:type]) ? [] :
        ( (options[:global_options] ? com.render_options : com.options) || {} ).
          keys.map {|e| Array(e)[0] }.flatten.map {|e| e.to_s}
      names_or_types.each {|e|
        # skip boolean options
        next if options[:skip_booleans] && !options[:type] &&
          (opt_parser.option_type(opt_parser.dasherize(e)) == :boolean)
        (a[e] ||= []) << com.name
      }
      a
    }
  end

  # @config :alias=>'fl'
  # Displays table's field lengths after executing command
  def field_lengths(*args)
    Boson.full_invoke args.shift, args
    if (table = ::Hirb::Helpers::Table.last_table)
      render [table.field_lengths], :fields =>table.fields
    else
      puts "No table detected"
    end
  end

  # @render_options :fields=>{:default=>[:name, :alias, :type, :desc],
  # :values=>[:filter, :type, :env, :no_render, :pipe, :bool_default, :alias, :keys, :solo, :desc, :name]}
  # List pipes
  def pipes
    Boson::OptionCommand.default_pipe_options.inject([]) {|t,(name,h)|
      t << h.merge(:name=>name)
    }
  end

  # @options :parse=>{:type=>:string, :bool_default=>true}, :raise_error=>:boolean, :any_response=>:boolean
  # A commandified version of get
  def fetch(url, opts={})
    get(url, opts)
  end

  # Use in console to make an existing command an option command
  def commandify(command)
    return "Command not found" unless (cmd = Boson::Command.find(command))
    cmd.make_option_command
    Boson::Scientist.redefine_command Boson.main_object, cmd
  end

  # Just echoes arguments to act as a command
  def echo(*args)
    args
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

  # @config :alias=>'gb'
  # @options :config=>:boolean
  # Grep in commands
  def grep_boson_repo(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    dirs = [options[:config] ? Boson.repo.config_dir : Boson.repo.commands_dir]
    args = ['grep', '-r'] + args + dirs
    system *args
  end

  # Tells you what methods in current binding aren't boson commands.
  def undetected_methods(priv=false)
    public_undetected = metaclass.instance_methods - (Kernel.instance_methods + Object.instance_methods(false) + MyCore::Object::InstanceMethods.instance_methods +
      Boson.commands.map {|e| [e.name, e.alias] }.flatten.compact)
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
