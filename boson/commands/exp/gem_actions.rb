module GemActions
  # @render_options :fields=>[:name, :summary, :homepage, :authors], :max_fields=>{:default=>{:authors=>0.1}}
  # @options :limit=>50
  def gemspecs(options={})
    ::Gem.source_index.gems.values[0,options[:limit]]
  end
end