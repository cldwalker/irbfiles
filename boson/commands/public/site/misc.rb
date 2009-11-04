module MiscLib
  def self.config
    {:dependencies=>['public/boson']}
  end

  # Downloads the raw form of a github repo file url
  def raw_file(file_url)
    download file_url.sub('blob','raw')
  end

  def analytics_day(start_date=nil, end_date=nil)
    start_date = start_date ? Date.parse("#{start_date}/2009") : Date.today
    start_date = start_date.strftime("%Y%m%d")
    end_date ||= start_date
    url = "https://www.google.com/analytics/reporting/?reset=1&id=14680769&pdr=#{start_date}-#{end_date}"
    browser url
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
end