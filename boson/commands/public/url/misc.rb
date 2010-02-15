module MiscUrl
  # @config :alias=>'ts'
  # Basic twitter search
  def twitter_search(*query)
    build_url "http://search.twitter.com/search", :q=>query
  end

  # @config :alias=>'tu'
  # User page
  def twitter_user(user)
    "http://twitter.com/#{user}"
  end

  # Search imdb
  def imdb_search(*query)
    build_url "http://www.imdb.com/find", :q=>query
  end

  def cutter_gem(rubygem)
    "http://www.gemcutter.org/gems/#{rubygem}"
  end

  # @config :alias=>'bts'
  # @options :remote=>:boolean
  # Machine tag search on my website or localhost version
  def blog_tag_search(mtag, options={})
    base_url = options[:remote] ? "http://tagaholic.me" : "http://localhost:4000"
    mtag = "*:*=#{mtag}" unless mtag[/:|=/]
    "#{base_url}/blog.html##{mtag}"
  end
end
