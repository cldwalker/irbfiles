module AliasLib
  def self.config
    command_aliases = YAML::load_file(File.expand_path("~/.alias.yml"))[:aliases][:instance_method]["Alias::Console"] rescue {}
    search_options = {:type=>:optional, :alias=>:optional, :class=>:optional, :name=>:optional}
    create_options = {:pretend=>false, :force=>false}
    commands_hash = {'search_aliases'=>{:options=>search_options}, 'create_aliases'=>{:options=>create_options}}
    {:command_aliases=>command_aliases, :commands_hash=>commands_hash}
  end

  def self.included(mod)
    require 'alias'
    eval "module ::MainCommands; end"
    Alias.create :file=>"~/.alias.yml", :verbose=>true
    mod.send :include, ::MainCommands
    mod.send :include, Alias::Console
  end
end