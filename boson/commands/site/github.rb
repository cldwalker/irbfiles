module Github
  # @render_options :fields=>{:default=>[:name, :watchers, :forks, :homepage, :description],
  #  :values=>[:homepage, :name, :forks, :private, :watchers, :fork, :url, :description, :owner, :open_issues]}
  # @options :user=>'cldwalker', :fork_included=>true, [:stats,:S]=>true
  # Displays a user's repositories
  def user_repos(options={})
    repos = github_get("/repos/show/#{options[:user]}")['repositories']
    repos = repos.select {|e| ! e[:fork] } unless options[:fork_included]
    if options[:stats]
      fork_average = repos.inject(0) {|t,e| t + e[:forks]} / repos.size.to_f
      watcher_average = repos.inject(0) {|t,e| t + e[:watchers]} / repos.size.to_f
      puts "Repos: #{repos.size}, Watchers: #{watcher_average}, Forks: #{fork_average}"
    end
    repos
  end

  # @render_options :fields=>{:values=>["score", "name", "size", "language", "followers", "type",
  #   "username", "id", "description", "forks", "fork", "pushed", "created"], :default=>['name','username',
  #   'followers','language','pushed','score','description']}, :sort=>'score', :reverse_sort=>true
  #  Search repositories
  def repo_search(query)
    github_get("/repos/search/#{query}")['repositories']
  end

  # @render_options :fields=>{:values=>[:homepage, :name, :watchers, :private, :forks, :fork, :url, :description, :owner, :open_issues],
  #  :default=>[:owner, :watchers, :forks, :homepage, :description]}
  # @options :user=>'cldwalker'
  # Displays network of a given user-repo i.e. wycats-thor or defunkt/rip
  def repo_network(user_repo, options={})
    user_repo = convert_user_repo(user_repo)
    user_repo = "#{options[:user]}/#{user_repo}" unless user_repo['/']
    github_get("/repos/show/#{user_repo}/network")['network']
  end

  # @render_options :fields=>{:values=>["score", "name", "language", "followers", "type", "fullname",
  #  "username", "id", "repos", "pushed", "created", "location"], :default=>['name', 'followers', 'repos',
  #  'pushed', 'language', 'location', 'score']}
  # Search users
  def user_search(query)
    github_get("/user/search/#{query}")['users']
  end

  # td: /commits/list/:user_id/:repository/:branch/*path
  # @render_options :fields=>{:values=>%w{id url committed_date authored_date message},
  #  :default=>%w{id authored_date message}}
  # @options :branch=>'master'
  # List commits of a given user-repo
  def commit_list(user_repo, options={})
    user_repo = convert_user_repo(user_repo)
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

  # sample url: http://github.com/takai/twitty-console
  # Clones a github repo and opens in textmate
  def checkout(url)
    user, repo = /github.com\/([^\/]+)\/([^\/]+)/.match(url)[1,2]
    if user.nil? || repo.nil? 
      puts "Couldn't match user or repo from url"
    else
      clone_url = "git://github.com/#{user}/#{repo}.git"
      cmd = "cd ~/code/world; git clone #{clone_url} && mate #{repo}"
      system(cmd)
    end
  end

  # boson library needed for download()
  # Downloads the raw form of a github repo file url
  def raw_file(file_url)
    download file_url.sub('blob','raw')
  end

  # Opens a repo with an optional path in a browser
  def repo(user_repo, file=nil)
    convert_user_repo(user_repo)
    repo_url = "http://github.com/#{convert_user_repo user_repo}"
    repo_url += "/blob/master/" + file if file
    browser repo_url
  end

  private
  def convert_user_repo(user_repo)
    user_repo.include?('-') ? user_repo.split('-', 2).join('/') : user_repo
  end

  def github_get(url)
    yaml_get("http://github.com/api/v2/yaml#{url}")
  end

  def yaml_get(url)
    YAML::load(get(url))
  end
end