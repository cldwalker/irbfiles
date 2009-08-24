module ShellCommands
  #install latest tabtab + copy files + git repo
  def tabtab
    cmd = "install_tabtab && cp -f ~/.tabtab.bash ~/code/repo/dotfiles/.bash/completion/.tabtab.bash"
    system(cmd)
  end

  #diffs my latest template gitignore with current dir gitignore
  def diff_gitignore
    system("diff .gitignore ~/code/tmpl/gitignore-gem")
  end

  #copies my latest template gitignore to current dir
  def cp_gitignore
    require 'fileutils'
    system "cp -fv ~/code/tmpl/gitignore-gem .gitignore"
  end
end