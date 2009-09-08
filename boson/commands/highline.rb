module Highline
  def self.included(mod)
    require 'highline'
  end

  def highline
    @highline ||= HighLine.new
  end
end