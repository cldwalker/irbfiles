module Github
  def self.included(mod)
    require 'cgi'
  end

  # @render_options :fields=>{:default=>[:name, :watchers, :forks, :homepage, :description, :url],
  #  :values=>[:homepage, :name, :forks, :private, :watchers, :fork, :url, :description, :owner, :open_issues]},
  #  :max_fields=>{:default=>{:homepage=>0.2, :url=>0.1} }
  # @options :user=>{:default=>'cldwalker', :desc=>'Github user' },
  #  [:forks,:F]=>{:type=>:boolean, :desc=>'Display forked repositories'}
  # Displays a user's repositories
  def user_repos(options={})
    repos = github_get("/repos/show/#{options[:user]}")['repositories']
    return puts("Invalid user '#{options[:user]}'") unless repos
    !options[:forks] ? repos.select {|e| ! e[:fork] } : repos
  end

  # @render_options :fields=>[:repo, :description, :created_at]
  # @options :user=>{:default=>'cldwalker', :desc=>'Github user'}
  # Displays a user's gists
  def user_gists(options={})
    gists = base_get("http://gist.github.com/api/v1/yaml/gists/#{options[:user]}")['gists']
    gists || puts("Invalid user '#{options[:user]}'")
  end

  # @render_options :fields=>{:values=>["score", "name", "size", "language", "followers", "type",
  #   "username", "id", "description", "forks", "fork", "pushed", "created"], :default=>['name','username',
  #   'followers','language','pushed','score','description']}, :sort=>'score', :reverse_sort=>true
  #  Search repositories
  def repo_search(query)
    github_get("/repos/search/#{CGI.escape(query)}")['repositories']
  end

  # @render_options :fields=>{:values=>[:homepage, :name, :watchers, :private, :forks, :fork, :url, :description, :owner, :open_issues],
  #  :default=>[:owner, :watchers, :forks, :homepage, :description, :url]}, :max_fields=>{:default=>{:url=>0.15}}
  # @options :user=>{:default=>'cldwalker', :desc=>'Github user'}
  # Displays network of a given user-repo i.e. wycats-thor or defunkt/rip
  def repo_network(user_repo, options={})
    user_repo = "#{options[:user]}/#{user_repo}" unless user_repo['/']
    github_get("/repos/show/#{user_repo}/network")['network']
  end

  # @render_options :fields=>{:values=>["score", "name", "language", "followers", "type", "fullname",
  #  "username", "id", "repos", "pushed", "created", "location"], :default=>['name', 'followers', 'repos',
  #  'pushed', 'language', 'location', 'score']}
  # Search users
  def user_search(query)
    github_get("/user/search/#{CGI.escape(query)}")['users']
  end

  # td: /commits/list/:user_id/:repository/:branch/*path
  # @render_options :fields=>{:values=>%w{id url committed_date authored_date message},
  #  :default=>%w{id authored_date message url}}, :max_fields=>{:default=>{'url'=>0.1}}
  # @options :branch=>{:default=>'master', :desc=>'Git repo branch'},
  #   :user=>{:default=>'cldwalker', :desc=>'Github user'}
  # List commits of a given user-repo
  def commit_list(user_repo, options={})
    user_repo = "#{options[:user]}/#{user_repo}" unless user_repo['/']
    github_get("/commits/list/#{user_repo}/#{options[:branch]}")['commits']
  end

  # @render_options :fields=>{:values=>[:owner, :homepage, :open_issues, :name, :url, :private,
  #  :fork, :watchers, :description, :forks], :default=>[:name, :owner, :watchers, :forks, :description]}
  # Lists repos watched by user
  def repos_watched(user)
    github_get("/repos/watched/#{user}")['repositories'].select {|e| e[:owner] != user }
  end

  # @render_options {}
  # List users a user follows
  def user_follows(user)
    github_get("/user/show/#{user}/following")['users']
  end

  private
  def base_get(url)
    (str = get(url, :success_only=>true)) ? YAML::load(str) : {}
  end

  def github_get(url)
    base_get "http://github.com/api/v2/yaml#{url}"
  end
end
