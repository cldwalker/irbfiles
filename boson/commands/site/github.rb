module Github
  # @render_options :fields=>{:default=>[:name, :watchers, :forks, :homepage, :description],
  #  :values=>[:homepage, :name, :forks, :private, :watchers, :fork, :url, :description, :owner, :open_issues]}
  # @options :user=>'cldwalker', :fork_included=>true
  def user_table(options={})
    repos = user_repos(options[:user])
    !options[:fork_included] ? repos.select {|e| ! e['fork'] } : repos
  end

  def issues(user='cldwalker')
    result = user_repos(user).map do |e|
      puts "Fetching open issues on #{e['name']}..."
      [e['name'], yaml_get("http://github.com/api/v2/yaml/issues/list/#{user}/#{e['name']}/open")['issues'] ]
    end
    render result.map {|e,f| [e, f.size] }
    result
  end
  
  #sample url: http://github.com/takai/twitty-console
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

  def raw_file(file_url)
    download file_url.sub('blob','raw')
  end

  def repo(user_repo, file=nil)
    convert_user_repo(user_repo)
    repo_url = "http://github.com/#{convert_user_repo user_repo}"
    repo_url += "/blob/master/" + file if file
    browser repo_url
  end

  # @render_options :fields=>{:values=>[:homepage, :name, :watchers, :private, :forks, :fork, :url, :description, :owner, :open_issues],
  #  :default=>[:owner, :watchers, :forks, :homepage, :description]}
  # @options :user=>'cldwalker'
  def repo_network(user_repo, options={})
    user_repo = convert_user_repo(user_repo)
    user_repo = "#{options[:user]}/#{user_repo}" unless user_repo['/']
    yaml_get("http://github.com/api/v2/yaml/repos/show/#{user_repo}/network")['network']
  end

  private
  def convert_user_repo(user_repo)
    user_repo.include?('-') ? user_repo.split('-', 2).join('/') : user_repo
  end

  def yaml_get(url)
    YAML::load(get(url))
  end

  def user_repos(user)
    yaml_get("http://github.com/api/v2/yaml/repos/show/#{user}")['repositories']
  end
end