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

  # @options :clone_directory=>'.', :editor=>'mate'
  # Clones a github repo or gist and opens in editor
  def checkout(repo_url, options={})
    clone_url,dest = clonable_url_and_name(repo_url)
    if clone_url && dest
      cmd = "cd #{options[:directory]}; git clone #{clone_url} #{dest} && #{options[:editor]} #{dest}"
      system cmd
    end
  end

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

  # Delete backup files left by text editors
  def delete_backups
    backups = Dir.glob('**/*~')
    menu(backups) do |paths|
      paths.each {|e| File.unlink(e) }
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

  # rip install for local git repository
  def rip_install(file='.')
    system 'rip','install', "file://"+File.expand_path(file)
  end
end
