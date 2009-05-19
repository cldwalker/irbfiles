module RestClient
  def self.init
    require 'restclient'
    [:head, :get, :post, :put, :update].each do |m|
      module_eval %[
        def #{m}(*args, &block)
          ::RestClient.#{m}(*args, &block)
        end
      ]
    end
  end
end