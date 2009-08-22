module Unroller
  def self.included(mod)
    require 'unroller'
  end

  def trace(*args, &block)
    ::Unroller.trace(*args, &block)
  end
end