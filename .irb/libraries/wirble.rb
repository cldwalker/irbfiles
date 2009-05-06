module Iam::Libraries::Wirble
  #loads pp, irb/completion, convenience methods for ri and object inspection (:ri, :po, :poc)
  def self.init
    require 'wirble'
    Wirble.init :skip_history=>true, :skip_shortcuts=>true, :skip_internals=>true
    #td: make better colorizing
    #Wirble.colorize
    #td: self.extend Wirble::Shortcuts
  end
end