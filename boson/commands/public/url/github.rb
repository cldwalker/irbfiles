module GithubUrl
  # @options :user=>{:default=>'cldwalker', :desc=>'Github user'},
  #  :file=>{:type=>:string, :desc=>'Relative file path within repository' }
  # Opens a repo with an optional path in a browser
  def repo(user_repo, options={})
    user_repo = default_user_repo(user_repo)
    user_repo = "#{options[:user]}/#{user_repo}" unless user_repo['/']
    repo_url = "http://github.com/#{user_repo}"
    repo_url += "/blob/master/" + options[:file] if options[:file]
    repo_url
  end

  private
  def default_user_repo(user_repo)
    user_repo.include?('-') ? user_repo.split('-', 2).join('/') : user_repo
  end
end