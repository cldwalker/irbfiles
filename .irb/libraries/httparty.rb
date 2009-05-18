module Iam::Libraries::Httparty
  def self.init
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