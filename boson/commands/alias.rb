module AliasLib
  def self.config
    command_aliases = YAML::load_file(File.expand_path("~/.alias.yml"))[:aliases][:instance_method]["Alias::Console"] rescue {}
    {:command_aliases=>command_aliases}
  end

  def self.included(mod)
    require 'alias'
    eval "module ::MainCommands; end"
    Alias.create :file=>"~/.alias.yml", :verbose=>true
    mod.send :include, ::MainCommands
    mod.send :include, Alias::Console
  end
end