module Delicious
  def self.included(mod)
    # maybe consider replacing with concise hand rolled lib: 
    # http://github.com/citizen428/unsavory/blob/37e0d2c211fa303e1a36adcc87ec66e4f7344312/lib/delicious.rb
    require 'www/delicious'
  end

  def delicious
    @delicious ||= ::WWW::Delicious.new(ENV['DELICIOUS_USER'], ENV['DELICIOUS_PASSWORD'])
  end
end