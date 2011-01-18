module Github
  def self.included(mod)
    require 'cgi'
  end

  # @render_options :fields=>{:default=>[:name, :watchers, :forks, :homepage, :description, :url],
  #  :values=>[:homepage, :name, :forks, :private, :watchers, :fork, :url, :description, :owner, :open_issues, :created_at, :pushed_at]},
  #  :max_fields=>{:default=>{:homepage=>0.2, :url=>0.1} }
  # @options :user=>{:default=>'cldwalker', :desc=>'Github user' },
  #  [:forks,:F]=>{:type=>:boolean, :desc=>'Display forked repositories'}
  # @config :menu=>{:command=>:browser, :default_field=>:url}
  # Displays a user's repositories
  def user_repos(options={})
    repos = github_get("/repos/show/#{options[:user]}")['repositories']
    return puts("Invalid user '#{options[:user]}'") unless repos
    !options[:forks] ? repos.select {|e| ! e[:fork] } : repos
  end

  # @render_options :fields=>[:repo, :description, :created_at]
  # @options :user=>{:default=>'cldwalker', :desc=>'Github user'}
  # @config :menu=>{:template=>'http://gist.github.com/:repo', :command=>:browser}
  # Displays a user's gists
  def user_gists(options={})
    gists = get("http://gist.github.com/api/v1/yaml/gists/#{options[:user]}", :parse=>true)['gists']
    gists || puts("Invalid user '#{options[:user]}'")
  end

  # @render_options :fields=>{:values=>[:score, :name, :size, :language, :followers, :type,
  #   :username, :id, :description, :forks, :fork, :pushed, :created], :default=>[:name, :username,
  #   :followers, :language, :pushed, :score, :description]}, :sort=>'score', :reverse_sort=>true
  # @config :menu=>{:command=>:browser, :template=>'http://github.com/:username/:name'}
  # @options :page=>1, :language=>:string
  #  Search repositories
  def repo_search(query, options={})
    github_get("/repos/search/#{CGI.escape(query)}?start_page=#{options[:page]}&language=#{options[:language]}")['repositories']
  end

  # @render_options :fields=>{:values=>[:homepage, :name, :watchers, :private, :forks, :fork, :url, :description, :owner, :open_issues],
  #  :default=>[:owner, :watchers, :forks, :homepage, :description, :url]}, :max_fields=>{:default=>{:url=>0.15}}
  # @options :user=>{:default=>'cldwalker', :desc=>'Github user'}
  # @config :menu=>{:command=>:browser, :default_field=>:url}
  # Displays network of a given user-repo i.e. wycats-thor or defunkt/rip
  def repo_network(user_repo, options={})
    github_get("/repos/show/#{filter_user_repo(user_repo, options)}/network")['network']
  end

  # @render_options :fields=>{:values=>["score", "name", "language", "followers", "type", "fullname",
  #  "username", "id", "repos", "pushed", "created", "location"], :default=>['name', 'followers', 'repos',
  #  'pushed', 'language', 'location', 'score']}
  # @config :menu=>{:command=>:browser, :template=>'http://github.com/:name'}
  # Search users
  def user_search(query)
    github_get("/user/search/#{CGI.escape(query)}")['users']
  end

  # td: /commits/list/:user_id/:repository/:branch/*path
  # @render_options :fields=>{:values=>%w{id url committed_date authored_date message},
  #  :default=>%w{id authored_date message url}}, :max_fields=>{:default=>{'url'=>0.1}}
  # @options :branch=>{:default=>'master', :desc=>'Git repo branch'},
  #   :user=>{:default=>'cldwalker', :desc=>'Github user'}
  # @config :menu=>{:command=>:browser, :default_field=>'url'}
  # List commits of a given user-repo
  def commit_list(user_repo, options={})
    github_get("/commits/list/#{filter_user_repo(user_repo, options)}/#{options[:branch]}")['commits']
  end

  # @render_options :fields=>{:values=>[:owner, :homepage, :open_issues, :name, :url, :private,
  #  :fork, :watchers, :description, :forks], :default=>[:name, :owner, :watchers, :forks, :description]}
  # @config :menu=>{:command=>:browser, :template=>'http://github.com/:owner/:name'}
  # Lists repos watched by user
  def repos_watched(user)
    github_get("/repos/watched/#{user}")['repositories'].select {|e| e[:owner] != user }
  end

  # @render_options {}
  # @options :user=>{:default=>'cldwalker', :desc=>'Github user'}
  # Lists a repo's watchers
  def repo_watchers(user_repo, options={})
    github_get("/repos/show/#{filter_user_repo(user_repo, options)}/watchers")['watchers']
  end

  # @render_options {}
  # @config :menu=>{:command=>:browser, :template=>'http://github.com/:to_s'}
  # List users a user follows
  def user_follows(user)
    github_get("/user/show/#{user}/following")['users']
  end

  private
  def filter_user_repo(user_repo, options)
    user_repo['/'] ? user_repo : "#{options[:user]}/#{user_repo}"
  end

  def github_get(url)
    get("http://github.com/api/v2/yaml#{url}", :parse=>true) || {}
  end
end
