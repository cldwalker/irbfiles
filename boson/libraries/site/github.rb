module Github
  def self.included(mod)
    require 'httparty'
  end

  def github_user(user='cldwalker')
    HTTParty.get("http://github.com/api/v2/json/repos/show/#{user}")
  end

  def github_user_table(user='cldwalker')
    table github_user(user)['repositories'].select {|e| !e['private']}, :fields=>%w{name watchers forks homepage description}
  end

  def github_issues(user='cldwalker')
    result = github_user(user)['repositories'].map do |e|
      puts "Fetching open issues on #{e['name']}..."
      [e['name'], HTTParty.get("http://github.com/api/v2/json/issues/list/#{user}/#{e['name']}/open")['issues'] ]
    end
    table result.map {|e,f| [e, f.size] }
    result
  end
end