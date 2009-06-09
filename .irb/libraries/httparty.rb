module Httparty
  def self.included(mod)
    require 'httparty'
    [:get, :post, :put, :update].each do |m|
      module_eval %[
        def #{m}(*args, &block)
          ::HTTParty.#{m}(*args, &block)
        end
      ]
    end
  end
end