module MiscUrl
  # @config :alias=>'ts'
  # Basic twitter search
  def twitter_search(query)
    "http://search.twitter.com/search?q=#{query}"
  end

  # @config :alias=>'tu'
  # User page
  def twitter_user(user)
    "http://twitter.com/#{user}"
  end

  # Search imdb
  def imdb_search(*query)
    "http://www.imdb.com/find?q=#{query.join(' ')}"
  end
end
