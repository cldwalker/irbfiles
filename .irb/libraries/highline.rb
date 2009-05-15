module Iam::Libraries::Highline
  def self.init
    require 'highline'
    [:agree, :ask, :choose, :say].each do |m|
      module_eval %[
        def #{m}(*args, &block)
          highline.#{m}(*args, &block)
        end
      ]
    end
  end

  def highline
    @highline ||= HighLine.new
  end
end