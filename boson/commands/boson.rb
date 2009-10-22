module BosonLib
  # @options :editor=>ENV['EDITOR'], :string=>:string, :file=>:string, :config=>:boolean,
  #  :library=>:string
  # Edit a file or string, boson's main config file or a boson library file
  def edit(options={})
    options[:editor] ||= ENV['EDITOR']
    file = options[:library] ? Boson::FileLibrary.library_file(options[:library], Boson.repo.dir) :
      options[:config] ? config_dir + '/boson.yml' : options[:file] || begin
        require 'tempfile'
        Tempfile.new('edit_string').path
      end
    File.open(file,'w') {|f| f.write(options[:string]) } if options[:string]
    system(options[:editor], file)
    File.open(file) {|f| f.read } if File.exists?(file) && options[:string]
  end

  # Show a library
  def show(lib)
    file = Boson::FileLibrary.library_file(lib, Boson.repo.dir)
    puts File.exists?(file) ? File.read(file) : "File '#{file}' doesn't exist"
  end

  # Uninstall a library
  def uninstall(lib)
    File.unlink Boson::FileLibrary.library_file(lib, Boson.repo.dir)
  end

  # List libraries that haven't been loaded yet
  def unloaded_libraries
    (Boson::Runner.all_libraries - Boson.libraries.map {|e| e.name }).sort
  end

  # Prints stats about boson's index
  def stats
    Boson::Index.read
    option_cmds = Boson::Index.commands.select {|e| !e.options.to_s.empty? }
    render_option_cmds = Boson::Index.commands.select {|e| !e.render_options.to_s.empty? }
    render [[:libraries, Boson::Index.libraries.size], [:commands, Boson::Index.commands.size],
      [:option_commands, option_cmds.size], [:render_option_commands, render_option_cmds.size], ]
  end

  # @options :all=>:boolean, :verbose=>true, :reset=>:boolean
  # Updates/resets index of libraries and commands
  def index(options={})
    File.unlink(Boson::Index.marshal_file) if options[:reset] && File.exists?(Boson::Index.marshal_file)
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
  # Config directory of main Boson repo
  def config_dir
    Boson.repo.config_dir
  end

  def determine_download_name(url)
    FileUtils.mkdir_p(File.join(Boson.repo.dir,'downloads'))
    basename = strip_name_from_url(url) || url.sub(/^[a-z]+:\/\//,'').tr('/','-')
    filename = File.join(Boson.repo.dir, 'downloads', basename)
    filename += "-#{Time.now.strftime("%m_%d_%y_%H_%M_%S")}" if File.exists?(filename)
    filename
  end
end
