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

  # @options :group=>{:type=>:string, :values=>%w{console tree tag}, :enum=>false}
  def whisper(*query)
    options = query[-1].is_a?(Hash) ? query.pop : {}
    if options[:group]
      groups = {
        'console'=>%w{console commandline shell irb},
        'tag'=>%w{tag tagging taggable triple},
        'tree'=>%w{tree hierarchy outline}
      }
      query = groups[options[:group]] || query
    end
    build_url "http://freezing-mist-54.heroku.com/", :query=>query
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
