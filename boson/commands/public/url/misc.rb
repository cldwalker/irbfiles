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

  def gem_page(rubygem)
    "http://rubygems.org/gems/#{rubygem}"
  end

  def manpage(cmd)
    "http://man.cx/#{cmd}"
  end

  def gem_family(rubygem)
    "http://gemfamily.info/gems/#{rubygem}"
  end

  def jquery_api(*query)
    build_url "http://api.jquery.com/", :s=>query
  end

  def prefix_cc(*query)
    "http://prefix.cc/#{query.join(' ')}"
  end

  # @options :group=>{:type=>:string, :values=>%w{console tree tag sites}, :enum=>false}, :local=>:boolean, :limit=>25
  # Call whisper app to search recent gems
  def whisper(*query)
    options = query[-1].is_a?(Hash) ? query.pop : {}
    if options[:group]
      query = whisper_groups[options[:group]] || query
    end
    url = options[:local] ? 'http://localhost:9393/' : 'http://young-snow-95.heroku.com/'
    build_url url, :query=>query, :limit=>options[:limit]
  end

  # Open gem doc
  def yardoc(rubygem)
    "http://rdoc.info/gems/#{rubygem}"
  end

  # @config :alias => 'cdoc'
  # Open core class doc
  def coredoc(arg)
    "http://ruby-doc.org/core/classes/#{arg}.html"
  end

  # @config :alias => 'sdoc'
  # Open stdlib doc
  def stddoc(lib)
    "http://ruby-doc.org/stdlib/libdoc/#{lib}/rdoc/"
  end

  # @config :alias=>'bts'
  # @options :remote=>:boolean
  # Machine tag search on my website or localhost version
  def blog_tag_search(mtag, options={})
    base_url = options[:remote] ? "http://tagaholic.me" : "http://localhost:4000"
    mtag = "*:*=#{mtag}" unless mtag[/:|=/]
    "#{base_url}/blog.html##{mtag}"
  end

  private
  # Can't be exposed due to command pipe on all url methods
  # Groups of keywords to search whisper
  def whisper_groups
    {
      'console'=>%w{console commandline shell irb terminal ascii},
      'tag'=>%w{tag tagging taggable triple semantic},
      'tree'=>%w{tree hierarchy outline},
      'sites'=>%w{delicious freebase}
      # thor, table, cli, repl, menu
    }
  end
end
