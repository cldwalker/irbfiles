module AliasLib
  def self.included(mod)
    require 'alias'
    eval "module ::MainCommands; end"
    Alias.create :file=>"~/.alias.yml", :verbose=>true
    mod.send :include, ::MainCommands
    mod.send :include, Alias::Console
  end
end