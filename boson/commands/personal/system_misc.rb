module SystemMisc
  # Install latest tabtab + copy files + git repo
  def tabtab
    cmd = "install_tabtab && cp -f ~/.tabtab.bash ~/code/repo/dotfiles/.bash/completion/.tabtab.bash"
    system(cmd)
  end

  # Diffs my latest template gitignore with current dir gitignore
  def diff_gitignore
    system("diff .gitignore ~/code/tmpl/gitignore-gem")
  end

  # Copies my latest template gitignore to current dir
  def cp_gitignore
    system "cp -fv ~/code/tmpl/gitignore-gem .gitignore"
  end

  # @options :file=>:boolean, :editor=>'vim -u NONE'
  # Open new file in or copy existing file into sandbox
  def try(basename=nil, options={})
    destination = File.expand_path("~/code/sandbox")
    if options[:file]
      return puts("Need a file") if basename.nil?
      cmd = "cp -iR #{basename} #{destination} && #{options[:editor]} #{File.join(destination, File.basename(basename))}"
      system(cmd)
    else
      basename ||= Time.now.to_f.to_s
      cmd = [options[:editor], File.join(destination, basename)].join(" ")
      system(cmd)
    end
  end

  # Opens google analytics for given date range
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

  # @options :force=>:boolean, :verbose=>true, :noop=>:boolean, :dir=>'~/code/world'
  # Deletes paths with menu and FileUtils
  def delete_paths(options={})
    dir = File.expand_path options.delete(:dir)
    menu(Dir.entries(dir)) do |paths|
      FileUtils.rm_r paths.map {|e| "#{dir}/#{e}"}, options
    end
  end
end