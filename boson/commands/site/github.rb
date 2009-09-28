module Github
  def self.included(mod)
    require 'httparty'
  end

  # @render_options :fields=>{:default=>%w{name watchers forks homepage description},
  #  :values=>["name", "watchers", "private", "url", "forks", "fork", "description", "homepage", "open_issues"]}
  # @options :user=>'cldwalker', :fork_included=>true
  def user_table(options={})
    repos = user_repos(options[:user])
    !options[:fork_included] ? repos.select {|e| ! e['fork'] } : repos
  end

  def issues(user='cldwalker')
    result = user_repos(user).map do |e|
      puts "Fetching open issues on #{e['name']}..."
      [e['name'], HTTParty.get("http://github.com/api/v2/json/issues/list/#{user}/#{e['name']}/open")['issues'] ]
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
    user_repo = user_repo.split('-', 2).join('/') unless user_repo.include?('/')
    repo_url = "http://github.com/#{user_repo}"
    repo_url += "/" + file if file
    browser repo_url
  end

  private
  def user_repos(user)
    HTTParty.get("http://github.com/api/v2/json/repos/show/#{user}")['repositories']
  end
end