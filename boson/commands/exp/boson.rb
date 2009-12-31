module BosonLib
  # @render_options :change_fields=>['arguments', 'commands']
  # @options :count=>true, :transform=>true
  def arguments(options={})
    Boson::Index.read
    hash = Boson::Index.commands.inject({}) {|t,com|
      (com.args || []).each {|arg|
        arg_name = options[:transform] ? arg[0].to_s.gsub(/^\*|s$/,'')  : arg[0]
        (t[arg_name] ||= []) << com.name
      }
      t
    }
    hash.inject({}) {|h,(k,v)|
      h[k] = options[:count] ? v.size : v.inspect
      h
    }
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