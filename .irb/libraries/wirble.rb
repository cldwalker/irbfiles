module Wirble
  def self.included(mod)
    require 'wirble'
    ::Wirble.init :skip_history=>true, :skip_shortcuts=>true, :skip_internals=>true
    #td: make better colorizing
    #Wirble.colorize
  end
end