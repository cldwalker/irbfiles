module TwitterLib
  def self.included(mod)
    require 'twitter'
  end

  # @options :user=>ENV['TWITTER_USER'], :password=>ENV['TWITTER_PASSWORD']
  # Just tweet it
  def tweet(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    p options
    user = options[:user]
    pass = options[:password]
    Twitter::Base.new(Twitter::HTTPAuth.new(user,pass)).update args.join(' ')
  end
end