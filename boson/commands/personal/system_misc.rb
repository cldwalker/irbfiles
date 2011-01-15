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

  # @options :clone_directory=>'.', :editor=>'vim'
  # Clones a github repo or gist and opens in editor
  def checkout(repo_url, options={})
    clone_url,dest = clonable_url_and_name(repo_url)
    if clone_url && dest
      cmd = "cd #{options[:directory]}; git clone #{clone_url} #{dest} && #{options[:editor]} #{dest}"
      system cmd
    end
  end

  # @options :private=>:boolean
  # Creates remote github repo from local git repo. Copied from github gem
  def github_local_create(options={})
    repo = File.basename(Dir.pwd)
    is_repo = !`git status`[/fatal/]
    raise "Not a git repository. Use gh create instead" unless is_repo
    github_user = `git config --get github.user`.chomp
    github_token = `git config --get github.token`.chomp
    created = `curl -F 'repository[name]=#{repo}' -F 'repository[public]=#{!options[:private].inspect}' -F 'login=#{github_user}' -F 'token=#{github_token}' https://github.com/repositories`
    if created =~ %r{You are being <a href="https://github.com/#{github_user}/([^"]+)"}
      system "git remote add origin git@github.com:#{github_user}/#{$1}.git"
      exec "git push origin master"
    else
      abort "Error creating repository"
    end
  end

  # Wrapper around `hub fork`
  def github_fork(user_repo, fork_dir='~/code/fork')
    Dir.chdir File.expand_path(fork_dir)
    system "hub clone #{user_repo}"
    if $? == 0
      Dir.chdir user_repo[/[^\/]+$/]
      exec 'hub fork'
    else
      "Clone failed"
    end
  end

  # @option :repeats, :desc=>'Only displays ones that are repeats of existing files', :type=>:boolean
  # Delete backup files left by text editors
  def delete_backups(options={})
    backups = Dir.glob('**/*{~,.sw[a-z]}', File::FNM_DOTMATCH)
    backups = backups.select {|e| File.exist? e.chomp("~") } if options[:repeats]
    menu(backups) do |paths|
      paths.each {|e| File.unlink(e) }
    end
  end

  # Renames chosen file to given name
  def rename_file(name, dir='.')
    menu(Dir.entries(dir)) {|chosen| chosen.each {|e| File.rename(e, name) } }
  end

  # @options :force=>:boolean, :verbose=>true, :noop=>:boolean, :dir=>'~/code/world'
  # Deletes paths with menu and FileUtils
  def delete_paths(options={})
    dir = File.expand_path options.delete(:dir)
    menu(Dir.entries(dir)) do |paths|
      FileUtils.rm_r paths.map {|e| "#{dir}/#{e}"}, options
    end
  end

  # @options :directories=>{:type=>:array, :default=>['~/.rip/*/*/*'] }, :delete=>:boolean
  # Delete empty directories
  def delete_empty_dirs(options={})
    dirs = Dir.glob(options[:directories].map {|e| File.expand_path(e)+'/'})
    dirs = dirs.select {|e|
      Dir.glob(e+'/**/*').all? {|f| File.directory?(f) }
    }
    if options[:delete]
      menu(dirs).each {|e| FileUtils.rm_r e }
    else
      dirs
    end
  end

  private
  def clonable_url_and_name(repo_url)
    if repo_url[/^\d+$/]
      ["git://gist.github.com/#{repo_url}.git", "gist-#{repo_url}"]
    elsif (id = repo_url[/gist.github.com\/(\d+)$/, 1])
      ["git://gist.github.com/#{id}.git", "gist-#{id}"]
    else
      user, repo = /github.com\/([^\/]+)\/([^\/]+)/.match(repo_url)[1,2]
      return  puts("Couldn't match user or repo from repo_url") if user.nil? || repo.nil?
      ["git://github.com/#{user}/#{repo}.git", repo]
    end
  end
end
