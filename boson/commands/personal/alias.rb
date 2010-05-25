module AliasLib
  def self.included(mod)
    require 'alias'
  end

  def self.after_included
    ::Alias.create :file=>"~/.alias.yml", :verbose=>true
  end

  # @render_options :sort=>{:values=>[:type, :alias, :class, :name]}
  # @options {:type=>:string, :alias=>:string, :class=>:string, :name=>:string}
  # Searches aliases
  def search_aliases(*args)
    (args.empty? || args[0].empty?) ? Alias.manager.all_aliases : Alias.manager.search(*args)
  end
end