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

  # Calls a gem subcommand
  def gem_command(*args)
    # system('sudo', 'gem', *args)
    ::Gem::CommandManager.instance.find_command(args.shift).invoke(*args)
  end

end