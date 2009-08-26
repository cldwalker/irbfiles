module Github
  def self.included(mod)
    require 'httparty'
  end

  def user_feed(user='cldwalker')
    HTTParty.get("http://github.com/api/v2/json/repos/show/#{user}")
  end

  def user_table(user='cldwalker')
    render user_feed(user)['repositories'].select {|e| !e['private']}, :fields=>%w{name watchers forks homepage description}
  end

  def issues(user='cldwalker')
    result = user_feed(user)['repositories'].map do |e|
      puts "Fetching open issues on #{e['name']}..."
      [e['name'], HTTParty.get("http://github.com/api/v2/json/issues/list/#{user}/#{e['name']}/open")['issues'] ]
    end
    render result.map {|e,f| [e, f.size] }
    result
  end
  
  #sample url: http://github.com/takai/twitty-console/tree/master
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
    file_url = file_url.sub('blob','raw')
    system("wget", file_url)
  end

  def repo(user_repo, file=nil)
    user_repo = user_repo.split('-', 2).join('/') unless user_repo.include?('/')
    repo_url = "http://github.com/#{user_repo}/tree/master"
    repo_url += "/" + file if file
    browser repo_url
  end
end