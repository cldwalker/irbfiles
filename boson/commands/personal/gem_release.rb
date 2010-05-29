module GemRelease
  def self.config
    {:dependencies=>['public/rake', 'personal/gh_pages/main'], :force=>true}
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
  def release(version, rubygem=current_gem)
    system "git push origin master"
    tag_release(version)
    rake('gem')
    system "gem push pkg/#{rubygem}-#{version}.gem"
    rdoc
    publish
  end

  # Prints gem version
  def version
    current_gemspec.version.to_s
  end

  # Array of files that aren't in git repo
  def manifest
    current_files = current_gemspec.files
    git_files = `git ls-files -z`.split("\0")
    current_files.select {|e| !git_files.include?(e) }
  end

  def current_gemspec
    @gemspec ||= eval(File.read('gemspec'), binding, 'gemspec')
  end

  # Run tests on multiple versions of ruby
  def test
    rvm_ruby = File.expand_path "~/.rvm/bin/ruby-"
    rubies = { "system"=>'/usr/bin/ruby', '1.9.2'=>"#{rvm_ruby}1.9.2-preview1", '1.8.7'=>"#{rvm_ruby}1.8.7-p249" }
    bacon = File.expand_path '~/.rip/active/bin/bacon'
    rubies.all? {|k,v|
      puts "Running tests with ruby #{k}"
      cmd = "#{v} #{bacon} -q -Ilib -I. test/*_test.rb"
      system cmd
      $?.success?
    }
  end

  # Run rcov on current test suite
  def rcov
    require 'rcov/rcovtask'
    Rcov::RcovTask.new do |t|
      t.libs << 'test'
      t.test_files = FileList['test/**/*_test.rb']
      t.rcov_opts = ["-T -x '/Library/Ruby/*,/Users/bozo/.rip/*'"]
      t.verbose = true
    end
    rake 'rcov'
    nil
  end

  # @options :user=>'CLDWALKER'
  # Build manpage
  def build_man(rubygem=current_gem, options={})
    str = "ronn -br --organization=#{options[:user]} --manual='#{rubygem.capitalize} Manual' man/*.ronn"
    system str
  end

  # @config :alias=>'cg'
  # Detect current gem's name
  def current_gem
    File.basename Dir.pwd
  end
end