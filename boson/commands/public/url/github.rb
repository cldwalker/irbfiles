module GithubUrl
  # @config :alias=>'ghs'
  # Github repo search
  def github_search(*query)
    build_url "http://github.com/search", :type=>"Repositories",:q=>query
  end

  # Gist page
  def gist_id(id)
    "http://gist.github.com/#{id}"
  end

  # @options :gist=>:boolean
  # @config :alias=>'gu'
  # Github or gist user page
  def github_user(user, options={})
    options[:gist] ? "http://gist.github.com/#{user}" : "http://github.com/#{user}"
  end

  # @option :user, :default=>'cldwalker', :desc=>'Github user'
  # @option :file, :type=>:string, :desc=>'Relative file path within repository'
  # @option :commit, :type=>:string, :desc=>'Commit page'
  # @option :issue, :type=>:string, :desc=>'Issue page'
  # @option :tree, :type=>:string, :desc=>'Tree page'
  # @option :subpage, :type=>:string, :values=>%w{readme wiki issues network commits traffic punch_card timeline edit branches},
  #    :enum=>false, :desc=>'Subpage belonging to repo', :bool_default=>'readme'
  # Opens a repo page or a subpage i.e. commit, tree, file in a browser
  def repo(user_repo=nil, options={})
    if user_repo.nil?
      user_repo = `git config remote.origin.url`.chomp.gsub(%r{.git$|^git@github.com:|^git://github.com/}, '')
      user_repo.sub!(/^\w+/, options[:user]) if options[:user]
    elsif !user_repo['/']
      user_repo = "#{options[:user]}/#{user_repo}"
    end
    repo_url = "http://github.com/#{user_repo}"
    if options[:file]
      repo_url << "/blob/master/" + options[:file]
    elsif options[:subpage]
      case options[:subpage]
      when 'wiki'     then repo_url.sub!('github.com', 'wiki.github.com')
      when 'traffic'  then repo_url << '/graphs/traffic'
      when 'readme'   then repo_url << '#readme'
      when 'timeline' then repo_url << '/graphs/impact'
      when 'punch_card' then repo_url << '/graphs/punch_card'
      else repo_url << "/#{options[:subpage]}"
      end
    elsif options[:commit]
      repo_url << "/commit/#{options[:commit]}"
    elsif options[:tree]
      repo_url << "/tree/#{options[:tree]}"
    elsif options[:issue]
      repo_url << "/issues#issue/#{options[:issue]}"
    end
    repo_url
  end

  # @option :user, :default=>'cldwalker', :desc=>'Github user'
  # @option :start, :default=>'master', :desc=>'Starting branch/commit/tag'
  # @option :end, :default=>'master', :desc=>'Ending branch/commit/tag'
  # Compare repos by branch or commit
  def repo_compare(user_repo, options={})
    user_repo = "#{options[:user]}/#{user_repo}" unless user_repo['/']
    "http://github.com/#{user_repo}/compare/#{options[:start]}...#{options[:end]}"
  end
end
