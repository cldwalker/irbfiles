module GemMisc
  # @option remote, type: :boolean, :desc => 'Install remote dependencies'
  # Uninstall, rebuild and install gem in current directory
  def re_gem(options={})
    rubygem = current_gem
    system("gem uninstall -Iax #{rubygem}")
    rake = File.exists? 'Gemfile' ? 'bundle exec rake' : 'rake'
    output = `#{rake} -T 2>/dev/null`
    if $?.success?
      output[/rake build/] ? system("rake build") : system("rake gem")
    else
      system("mkdir -p pkg; gem build #{rubygem}.gemspec; mv #{rubygem}-#{version}.gem pkg")
    end
    system("gem install pkg/#{rubygem}-#{version}.gem #{options[:remote] ? '' : '--local'}")
  end

  # Deletes all gems in current gem list
  def nuke_gems
    system('gem list | cut -d" " -f1 | xargs gem uninstall -aIx')
  end
end
