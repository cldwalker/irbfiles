module GemBrain
  def self.included(mod)
    require 'yaml'
    require 'rubygems'
  end

  def self.config
    {:dependencies=>['exp/gem_actions']}
  end

  # @render_options :sort=>{:enum=>false, :values=>%w{to_s}}
  # @options :type=>{:type=>:string, :default=>:unapproved, :values=>[:github, :query, :approved, :unapproved, :tagged, :strip_users]}
  # List gems
  def list(options={})
    gems = case options[:type]
    when :github      then github_gems
    when :approved    then approved_gems
    when :unapproved  then unapproved_gems
    when :tagged      then untagged_gems
    when :strip_users then strip_users(gems)
    when :query       then all_gems(options[:query])
    else
      all_gems
    end
  end

  # @options :query=>'', :sudo=>:boolean, :opts=>:string
  # Execute gem command for matching gems
  def execute(subcommand, options={})
    local_commands = %w{add remove}
    local_command = local_commands.find {|e| e =~ /^#{subcommand}/}
    args = ['gem', subcommand]
    args.unshift 'sudo' if options[:sudo]
    menu(all_gems(options[:query]), :ask=>false) do |e|
      puts "Executing #{local_command || subcommand} for #{e.inspect}"
      local_command ? send(local_command, *e) : options[:opts] ?
        Boson.full_invoke(subcommand, (e << options[:opts]).join(' ')) : system(*(args + e))
    end
  end

  # Add gem to approved list
  def add(rubygem)
    GemBrain.add(rubygem)
  end

  # @options :uninstall=>:boolean
  # Recursively uninstall gem and remove it from approved list
  def remove(rubygem, options={})
    gem_recursive_uninstall(rubygem) if options[:uninstall]
    GemBrain.remove(rubygem)
  end

  # Version of currently loaded gem starting with name
  def version(rubygem)
    (spec = Gem.loaded_specs.values.find {|e| e.name =~ /(-|^)#{rubygem}/ }) &&
      spec.version.to_s
  end

  # @render_options :fields=>{:values=>[:name, :tags]}
  # List gems + their tags
  def tagged_gems
    GemTagger.tag_config.map {|k,v| {:name=>k, :tags=>v.join(',')} }
  end

  # @options :tags=>[], :menu=>:boolean
  # Tag gem(s)
  def tag(*rubygems)
    options = rubygems[-1].is_a?(Hash) ? rubygems.pop : {}
    rubygems = menu(untagged_gems) if options[:menu]
    return "Tags required" if options[:tags].empty?
    GemTagger.add(rubygems, options[:tags])
  end

  private
  # work around for block bug
  def menu(*args, &block)
    Boson.invoke(:menu, *args, &block)
  end

  def approved_gems
    GemBrain.gem_config[:approved].sort
  end

  def strip_users(gems)
    ghub_gems = github_gems + GemBrain.gem_config[:github]
    gems.map {|e| ghub_gems.include?(e) ? e.split('-', 2)[-1]: e}
  end

  def recursive_dependencies(rubygem)
    gem_dependencies(rubygem).map {|e| [e] + recursive_dependencies(e) }.flatten.uniq
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
      approved = gem_config[:approved]
      approved.delete(name.to_s)
      save(approved)
    end

    def add(name)
      save gem_config[:approved] << name
    end

    def save(approved)
      new_config = gem_config.merge(:approved=>approved)
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
