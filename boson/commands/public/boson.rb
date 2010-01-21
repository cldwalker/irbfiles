module BosonLib
  # @options :editor=>{:default=>ENV['EDITOR'], :desc=>'Editor to use for editing'},
  #  :string=>{:type=>:string, :desc=>'Edit string'},
  #  :file=>{:type=>:string, :desc=>'Edit file'},
  #  :config=>{:type=>:boolean, :desc=>'Edit main boson config file'},
  #  :library=>{:type=>:string, :desc=>'Edit boson library'},
  #  [:command, :L]=>{:type=>:string, :desc=>'Edit boson command' }
  # Edit a file or string, boson's main config file or a boson library file
  def edit(options={})
    options[:editor] ||= ENV['EDITOR']
    file = if options[:library]
      Boson::FileLibrary.library_file(options[:library], Boson.repo.dir)
    elsif options[:command]
      Boson::Index.read
      (lib = Boson.library Boson::Runner.autoload_command(options[:command])) &&
      lib.lib_file
    elsif options[:config]
      config_dir + '/boson.yml'
    else
      options[:file] || begin
        require 'tempfile'
        Tempfile.new('edit_string').path
      end
    end
    File.open(file,'w') {|f| f.write(options[:string]) } if options[:string]
    system(options[:editor], file || '')
    File.open(file) {|f| f.read } if File.exists?(file) && options[:string]
  end

  # @render_options :method=>'puts'
  # Show a library
  def show_library(lib_path)
    file = Boson.repos.map {|e| Boson::FileLibrary.library_file(lib_path, e.dir) }.
      find {|e| File.exists?(e) }
    file ? File.read(file) : "Library file doesn't exist"
  end

  # Uninstall a library
  def uninstall(lib_path)
    file = Boson::FileLibrary.library_file(lib_path, Boson.repo.dir)
    File.unlink file
    puts("Deleted '#{file}'.")
  end

  # List libraries that haven't been loaded yet
  def unloaded_libraries
    (Boson::Runner.all_libraries - Boson.libraries.map {|e| e.name }).sort
  end

  # Prints stats about boson's index
  def index_stats
    Boson::Index.read
    Boson::Index.indexes.each do |repo|
      option_cmds = repo.commands.select {|e| !e.options.to_s.empty? }
      render_option_cmds = repo.commands.select {|e| !e.render_options.to_s.empty? }
      puts "\n=== Repo at #{repo.repo.dir} ==="
      render [[:libraries, repo.libraries.size], [:commands, repo.commands.size],
        [:option_commands, option_cmds.size], [:render_option_commands, render_option_cmds.size], ]
    end
    nil
  end

  # Aliases a command
  def alias_command(command, command_alias)
    config_file = config_dir + '/boson.yml'
    config = YAML::load_file(config_file)
    (config[:command_aliases] ||= {})[command] = command_alias
    File.open(config_file, 'w') {|f| f.write config.to_yaml }
    "Success"
  end

  private
  # Config directory of main Boson repo
  def config_dir
    Boson.repo.config_dir
  end
end
