module GemMisc
  # Uninstall, rebuild and install gem in current directory
  def re_gem
    rubygem = current_gem
    system("gem uninstall -Iax #{rubygem}")
    `rake -T`
    if $?.success?
      system("rake gem")
    else
      system("mkdir -p pkg; gem build #{rubygem}.gemspec; mv #{rubygem}-#{version}.gem pkg")
    end
    system("gem install pkg/#{rubygem}-#{version}.gem")
  end

  # Deletes all gems in current gem list
  def nuke_gems
    system('gem list | cut -d" " -f1 | xargs gem uninstall -aIx')
  end
end
