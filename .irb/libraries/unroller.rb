module Unroller
  def self.init
    require 'unroller'
  end

  def trace(*args, &block)
    ::Unroller.trace(*args, &block)
  end
end