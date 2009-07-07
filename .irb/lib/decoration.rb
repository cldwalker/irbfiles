# from http://blog.rubybestpractices.com/posts/gregory/008-decorator-delegator-disco.html
require 'delegate'

# with minor tweaks from tjstankus
module Decoration
  def decorator_for(*types, &block)
    types.each do |type|
      decorators[type] = Module.new(&block)
    end
  end
 
  def decorators
    @decorators ||= {}
  end
 
  def decorate(target)
    obj = SimpleDelegator.new(target)
    
    # walk in reverse order so most specific patches get applied LAST
    target.class.ancestors.reverse.each do |a|
      if decorators[a]
        obj.extend(decorators[a])
      end
    end
    
    return obj
  end
end