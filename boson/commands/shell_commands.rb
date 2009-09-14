# Misc shell commands
module ShellCommands
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

  # options :file=>:boolean, :editor=>'vim -u NONE'
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
end