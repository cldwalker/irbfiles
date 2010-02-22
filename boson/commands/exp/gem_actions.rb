module GemActions
  # @render_options :fields=>[:name, :summary, :homepage, :authors], :max_fields=>{:default=>{:authors=>0.1}}
  # @config :menu=>{:command=>:gem_uninstall}
  # @options :limit=>200
  def gemspecs(options={})
    ::Gem.source_index.gems.values.inject({}) {|t,e| t[e.name] ||= e; t }.values[0,options[:limit]]
  end

  # Uninstall rubygems
  def gem_uninstall(*rubygems)
    system('sudo', 'gem', 'uninstall', *rubygems)
  end

  # Dependencies that depend on a gem
  def reverse_dependencies(rubygem)
    ::Gem.source_index.gems.values.select {|e| e.dependencies.any? {|e| e.name == rubygem && e.type == :runtime}}.
      map {|e| "#{e.name}-#{e.version}" }
  end

  # Runtime dependencies for latest version of gem
  def gem_dependencies(rubygem)
    (latest = latest_gemspec(rubygem)) ?
      latest.dependencies.select {|e| e.type == :runtime }.map {|e| e.name} : []
  end

  # Uninstall gem and all its dependencies
  def gem_recursive_uninstall(rubygem)
    deps = gem_dependencies(rubygem)
    puts "\n== Specify gem dependencies to remove:\n"
    gems = [rubygem] + menu(deps)
    gem_uninstall *gems
    puts("Uninstalled gems: #{gems.join(', ')}")
  end

  # Gemspec for latest version of gem
  def latest_gemspec(rubygem)
    ::Gem.source_index.gems.values.select {|e| e.name == rubygem }.sort_by {|e| e.version }[-1]
  end

  # Calls a gem subcommand
  def gem_command(*args)
    # system('sudo', 'gem', *args)
    ::Gem::CommandManager.instance.find_command(args.shift).invoke(*args)
  end

end