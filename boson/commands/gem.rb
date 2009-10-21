module GemLib
  def self.included(mod)
    require 'yaml'
  end

  # @render_options :sort=>{:enum=>false, :values=>%w{to_s}}
  # @options :github=>:boolean, :query=>:string, :approved=>:boolean, :unapproved=>:boolean,
  #  [:strip_users, :S]=>:boolean
  # List gems
  def list(options={})
    gems = options[:github] ? github_gems : (options[:approved] ? approved_gems :
      options[:unapproved] ? unapproved_gems : all_gems(options[:query]))
    options[:strip_users] ? strip_users(gems) : gems
  end

  # @options :query=>'', :sudo=>:boolean
  # Execute gem command for matching gems
  def execute(command, options={})
    local_commands = %w{add recursive_uninstall remove reverse_dependencies}
    local_command = local_commands.find {|e| e =~ /^#{command}/}
    args = ['gem', command]
    args.unshift 'sudo' if options[:sudo]
    menu(all_gems(options[:query]), :ask=>false) do |e|
      puts "Executing #{local_command || command} for #{e.inspect}"
      local_command ? send(local_command, *e) : system(*(args + e))
    end
  end

  # Uninstall gem and all its dependencies
  def recursive_uninstall(name)
    deps = dependencies(name)
    if deps.empty?
      system('sudo','gem','uninstall',name)
    else
      puts("Uninstall #{name} with dependencies: #{deps.join(', ')}? [y/n]")
      if gets.chomp[/y/]
        system(*(%w{sudo gem uninstall} + [name] + deps))
      else
        false
      end
    end
  end

  # Add gem to approved list
  def add(name)
    gem_save(gem_config[:approved] << name)
  end

  # Recursively uninstall gem and remove it from approved list
  def remove(name)
    if gem_recursive_uninstall(name)
      approved = gem_config[:approved]
      approved.delete(name.to_s)
      gem_save(approved)
    end
  end

  # Runtime dependencies for latest version of gem
  def dependencies(name)
    if (latest = latest_gemspec(name))
      latest.dependencies.select {|e| e.type == :runtime }.map {|e| e.name}
    else
      []
    end
  end

  # Gemspec for latest version of gem
  def latest_gemspec(name)
    ::Gem.source_index.gems.values.select {|e| e.name == name }.sort_by {|e| e.version }[-1]
  end

  # Dependencies that depend on a gem
  def reverse_dependencies(name)
    ::Gem.source_index.gems.values.select {|e| e.dependencies.any? {|e| e.name == name && e.type == :runtime}}.
      map {|e| "#{e.name}-#{e.version}" }
  end

  # Version of currently loaded gem starting with name
  def version(name)
    (spec = Gem.loaded_specs.values.find {|e| e.name =~ /(-|^)#{name}/ }) &&
      spec.version.to_s
  end

  private
  def strip_users(gems)
    ghub_gems = github_gems + gem_config[:github]
    gems.map {|e| ghub_gems.include?(e) ? e.split('-', 2)[-1]: e}
  end

  def gem_save(approved_gems)
    new_config = gem_config.merge(:approved=>approved_gems)
    File.open(gem_file, 'w') {|f| f.write(new_config.to_yaml) }
  end

  def recursive_dependencies(name)
    dependencies(name).map {|e| [e] + recursive_dependencies(e) }.flatten.uniq
  end

  def unapproved_gems
    yaml = gem_config
    all_gems - yaml[:approved] - yaml[:system] - yaml[:approved].map {|e| recursive_dependencies(e)}.flatten - yaml[:exception]
  end

  def approved_gems
    render gem_config[:approved].sort
  end

  def all_gems(query='')
    ::Gem.source_index.gems.values.map {|e| e.name}.uniq.grep(/#{query}/)
  end

  def github_gems
    ::Gem.source_index.gems.values.select {|e| e.homepage && e.homepage[/github/] }.map {|e| e.name}
  end

  def gem_config
    YAML::load_file(gem_file)
  end

  def gem_file
    File.join(Boson.repo.config_dir, 'gems.yml')
  end
end