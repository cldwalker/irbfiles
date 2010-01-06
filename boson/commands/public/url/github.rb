module GithubUrl
  # @config :alias=>'ghs'
  # Github repo search
  def github_search(*query)
    "http://github.com/search?type=Repositories&q=#{query.join(' ')}"
  end

  # @options :gist=>:boolean
  # @config :alias=>'gu'
  # Github or gist user page
  def github_user(user, options={})
    options[:gist] ? "http://gist.github.com/#{user}" : "http://github.com/#{user}"
  end

  # @options :user=>{:default=>'cldwalker', :desc=>'Github user'},
  #  :file=>{:type=>:string, :desc=>'Relative file path within repository' },
  #  :subpage=>{:type=>:string, :values=>%w{readme wiki issues network commits traffic punch_card timeline},
  #    :desc=>'Subpage belonging to repo', :bool_default=>'readme' }
  # Opens a repo with an optional path in a browser
  def repo(user_repo, options={})
    user_repo = default_user_repo(user_repo)
    user_repo = "#{options[:user]}/#{user_repo}" unless user_repo['/']
    repo_url = "http://github.com/#{user_repo}"
    if options[:file]
      repo_url << "/blob/master/" + options[:file]
    elsif options[:subpage]
      case options[:subpage]
      when 'wiki'    then repo_url.sub!('github.com', 'wiki.github.com')
      when 'issues'  then repo_url << '/issues'
      when 'network' then repo_url << '/network'
      when 'commits' then repo_url << '/commits'
      when 'traffic' then repo_url << '/graphs/traffic'
      when 'punch_card' then repo_url << '/graphs/punch_card'
      when 'timeline' then repo_url << '/graphs/impact'
      else
        repo_url << '#readme'
      end
    end
    repo_url
  end

  private
  def default_user_repo(user_repo)
    user_repo.include?('-') ? user_repo.split('-', 2).join('/') : user_repo
  end
end