module GemBrain
  def self.included(mod)
    require 'yaml'
  end

  # @render_options :sort=>{:enum=>false, :values=>%w{to_s}}
  # @options :github=>:boolean, :query=>:string, :approved=>:boolean, :unapproved=>:boolean,
  #  [:strip_users, :S]=>:boolean, :tagged=>:boolean
  # List gems
  def list(options={})
    gems = options[:github] ? github_gems : (options[:approved] ? approved_gems :
      options[:unapproved] ? unapproved_gems : options[:tagged] ? untagged_gems : all_gems(options[:query]))
    options[:strip_users] ? strip_users(gems) : gems
  end

  # @options :query=>'', :sudo=>:boolean, :opts=>:string
  # Execute gem command for matching gems
  def execute(command, options={})
    local_commands = %w{add recursive_uninstall remove reverse_dependencies}
    local_command = local_commands.find {|e| e =~ /^#{command}/}
    args = ['gem', command]
    args.unshift 'sudo' if options[:sudo]
    menu(all_gems(options[:query]), :ask=>false) do |e|
      puts "Executing #{local_command || command} for #{e.inspect}"
      local_command ? send(local_command, *e) : options[:opts] ?
        Boson.full_invoke(command, (e << options[:opts]).join(' ')) : system(*(args + e))
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
    GemBrain.add(name)
  end

  # @options :uninstall=>:boolean
  # Recursively uninstall gem and remove it from approved list
  def remove(name, options={})
    recursive_uninstall(name) if options[:uninstall]
    GemBrain.remove(name)
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

  # @render_options :fields=>{:values=>[:name, :tags]}
  # List gems + their tags
  def tagged_gems
    GemTagger.tag_config.map {|k,v| {:name=>k, :tags=>v.join(',')} }
  end

  # @options :tags=>[], :menu=>:boolean
  # Tag gem(s)
  def tag(*gems)
    options = gems[-1].is_a?(Hash) ? gems.pop : {}
    gems = menu(untagged_gems) if options[:menu]
    return "Tags required" if options[:tags].empty?
    GemTagger.add(gems, options[:tags])
  end

  private
  def approved_gems
    GemBrain.gem_config[:approved].sort
  end

  def strip_users(gems)
    ghub_gems = github_gems + GemBrain.gem_config[:github]
    gems.map {|e| ghub_gems.include?(e) ? e.split('-', 2)[-1]: e}
  end

  def recursive_dependencies(name)
    dependencies(name).map {|e| [e] + recursive_dependencies(e) }.flatten.uniq
  end

  def untagged_gems
    approved_gems - GemTagger.tag_config.keys
  end

  def unapproved_gems
    yaml = GemBrain.gem_config
    all_gems - yaml[:approved] - yaml[:system] - yaml[:approved].map {|e| recursive_dependencies(e)}.flatten - yaml[:exception]
  end

  def all_gems(query='')
    ::Gem.source_index.gems.values.map {|e| e.name}.uniq.grep(/#{query}/)
  end

  def github_gems
    ::Gem.source_index.gems.values.select {|e| e.homepage && e.homepage[/github/] }.map {|e| e.name}
  end

  class <<self
    def remove(name)
      approved = config[:approved]
      approved.delete(name.to_s)
      save(approved)
    end

    def add(name)
      save config[:approved] << name
    end

    def save(approved)
      new_config = config.merge(:approved=>approved)
      File.open(gem_file, 'w') {|f| f.write(new_config.to_yaml) }
    end

    def gem_config
      YAML::load_file(gem_file)
    end

    def gem_file
      File.join(Boson.repo.config_dir, 'gems.yml')
    end
  end

  module GemTagger
    extend self
    def add(gems, tags)
      new_config = tag_config
      gems.each {|e| new_config[e] = tags }
      save_config(new_config)
    end

    def remove(name)
      save_config(config.delete(name))
    end

    def save_config(new_config)
      File.open(tags_file, 'w') {|f| f.write(new_config.to_yaml) }
    end

    def tag_config
      File.exists?(tags_file) ? YAML::load_file(tags_file) : {}
    end

    def tags_file
      File.join(Boson.repo.config_dir, 'gem_tags.yml')
    end
  end
end