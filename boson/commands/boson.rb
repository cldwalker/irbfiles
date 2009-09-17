module BosonLib
  # Config directory of main Boson repo
  def config_dir
    Boson.repo.config_dir
  end

  # Edit a library
  def edit_library(name)
    file = Boson::FileLibrary.library_file(name.to_s, Boson.repo.dir)
    system("vim", file)
  end

  # Get command object by name or alias
  def boson_command(name)
    Boson.command(name) || Boson.command(name, :alias)
  end

  # Get library object by name or alias
  def boson_library(name)
    Boson.library(name) || Boson.library(name, :alias)
  end

  desc "Downloads a url and saves to a local boson directory"
  def download(url)
    filename = determine_download_name(url)
    File.open(filename, 'w') { |f| f.write get(url) }
    filename
  end

  # @options :sort=>:string, :output_method=>:string, :all_fields=>:boolean, :number=>:boolean,
  # :vertical=>:boolean
  # Wrapper around render with options
  def view(*args)
    render(*args)
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