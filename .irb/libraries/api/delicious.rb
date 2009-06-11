module Delicious
  def self.included(mod)
    require 'www/delicious'
  end

  def delicious
    @delicious ||= ::WWW::Delicious.new(ENV['DELICIOUS_USER'], ENV['DELICIOUS_PASSWORD'])
  end
end