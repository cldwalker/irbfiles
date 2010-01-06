module MiscUrl
  # @config :alias=>'ts'
  # Basic twitter search
  def twitter_search(query)
    "http://search.twitter.com/search?q=#{query}"
  end

  # Search imdb
  def imdb_search(*query)
    "http://www.imdb.com/find?q=#{query.join(' ')}"
  end
end