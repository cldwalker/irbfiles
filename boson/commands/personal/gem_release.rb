module GemRelease
  def self.config
    {:dependencies=>['public/rake', 'personal/gh_pages/main']}
  end

  # @options :file=>:string, :bump_type=>{:default=>'patch', :values=>['major','minor','patch']}
  # Bumps version in a version file
  def bump(options={})
    version_file = options[:file] || Dir['**/version.rb'][0] || raise("No version file found")
    version_string = File.read(version_file)
    new_version = nil
    version_string.sub!(/(\d+)\.(\d+)\.(\d+)/) {|e|
      major, minor, patch = $1.to_i, $2.to_i, $3.to_i
      new_version = case options[:bump_type]
      when 'major' then "#{major+1}.#{minor}.#{patch}"
      when 'minor' then "#{major}.#{minor+1}.#{patch}"
      else              "#{major}.#{minor}.#{patch+1}"
      end
    }
    File.open(version_file, 'w') {|f| f.write version_string }
    "Updated '#{version_file}' to '#{new_version}'"
  end

  # Tags release with current version
  def tag_release(version)
    system "git tag v#{version}"
    system "git push origin v#{version}"
  end

  # Releases gem
  def release(rubygem, version)
    system "git push origin master"
    tag_release(version)
    rake('gem')
    system "gem push pkg/#{rubygem}-#{version}.gem"
    rdoc
    publish
  end
end