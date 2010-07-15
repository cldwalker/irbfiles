module Release
  def self.config
    {:dependencies=>['public/rake']}
  end

  # @options :rubygem=>'', :version=>:numeric
  # Releases gem
  def release(options={})
    options[:rubygem] = current_gem if options[:rubygem].empty?
    options[:version] ||= version
    system "git push origin master"
    tag_release(options[:version])
    rake('gem')
    system "gem push pkg/#{options[:rubygem]}-#{options[:version]}.gem"
  end

  # Prints gem version
  def version
    current_gemspec.version.to_s
  end

  # @options :reverse=>:boolean
  # Array of files that aren't in git repo or vice versa
  def manifest(options={})
    current_files = current_gemspec.files
    git_files = `git ls-files -z`.split("\0")
    options[:reverse] ? git_files.select {|e| !current_files.include?(e) } :
      current_files.select {|e| !git_files.include?(e) }
  end

  # @options :file=>:string, :bump_type=>{:default=>'patch', :values=>['major','minor','patch']}
  # Bumps version in a version file and checks in to git
  def bump(options={})
    new_version = bump_file(options)
    system "git commit -am 'Bumped to version #{new_version}'"
  end

  def bump_file(options)
    version_file = options[:file] || Dir['**/version.rb'][0] || raise("No version file found")
    version_string = File.read(version_file)
    new_version = nil
    version_string.sub!(/(\d+)\.(\d+)\.(\d+)/) {|e|
      major, minor, patch = $1.to_i, $2.to_i, $3.to_i
      new_version = case options[:bump_type]
      when 'major' then "#{major+1}.0.0"
      when 'minor' then "#{major}.#{minor+1}.0"
      else              "#{major}.#{minor}.#{patch+1}"
      end
    }
    File.open(version_file, 'w') {|f| f.write version_string }
    new_version
  end

  # Tags release with current version
  def tag_release(version)
    system "git tag v#{version}"
    system "git push origin v#{version}"
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

  # @options :dev=>:boolean
  # Creates deps.rip from gemspec for runtime or dev dependencies
  def deps_rip(options={})
    type = options[:dev] ? :development : :runtime
    file = options[:dev] ? 'test/deps.rip' : 'deps.rip'
    deps = current_gemspec.dependencies.select {|e| e.type == type }.map {|e|
      [e.name, e.requirements_list.join(' ').gsub(/\s*/, '')] }
    if deps.size > 0
      File.open(file, 'w') {|f| f.write deps.map {|e| e.join(' ') }.join("\n") }
      file
    end
  end

  private
  def current_gemspec
    @gemspec ||= eval(File.read('.gemspec'), binding, '.gemspec')
  end

end
