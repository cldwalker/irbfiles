module AliasLib
  def self.config
    command_aliases = YAML::load_file(File.expand_path("~/.alias.yml"))[:aliases][:instance_method]["Alias::Console"] rescue {}
    create_options = {:pretend=>false, :force=>false}
    commands = {'create_aliases'=>{:options=>create_options, :args=>3}}
    {:command_aliases=>command_aliases, :commands=>commands}
  end

  def self.included(mod)
    require 'alias'
    Alias::Console.send :extend, self
  end

  def self.after_included
    Alias.create :file=>"~/.alias.yml", :verbose=>true
  end

  # @render_options :sort=>{:values=>[:type, :alias, :class, :name]}
  # @options {:type=>:string, :alias=>:string, :class=>:string, :name=>:string}
  # Searches aliases
  def search_aliases(*args)
    (args.empty? || args[0].empty?) ? Alias.manager.all_aliases : Alias.manager.search(*args)
  end
end