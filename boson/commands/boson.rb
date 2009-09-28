module BosonLib
  # Config directory of main Boson repo
  def config_dir
    Boson.repo.config_dir
  end

  # @options :editor=>ENV['EDITOR'], :string=>:string, :file=>:string
  # Edit a file or string
  def edit(options={})
    options[:editor] ||= ENV['EDITOR']
    file = options[:file] || begin
      require 'tempfile'
      Tempfile.new('edit_string').path
    end
    File.open(file,'w') {|f| f.write(options[:string]) } if options[:string]
    system(options[:editor], file)
    File.open(file) {|f| f.read } if File.exists?(file) && options[:string]
  end

  # Edit a library
  def edit_library(name)
    file = Boson::FileLibrary.library_file(name.to_s, Boson.repo.dir)
    edit :file=>file
  end

  # Prints stats about boson's index
  def stats
    Boson::Index.read
    render [[:libraries, Boson::Index.libraries.size], [:commands, Boson::Index.commands.size]]
  end

  # @options :all=>:boolean, :verbose=>true, :reset=>:boolean
  # Updates index
  def index(options={})
    File.unlink(Boson::Index.marshal_file) if options[:reset]
    Boson::Index.update(options)
  end

  # Get command object by name or alias
  def boson_command(name)
    Boson::Command.find(name)
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

  options :sort=>:string, :output_method=>:string, :all_fields=>:boolean, :number=>:boolean,
    :vertical=>:boolean
  desc "Wrapper around render with options"
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
