module GemRelease
  def self.config
    {:dependencies=>['public/release', 'exp/paz', 'exp/readme']}
  end

  # Checklist to run before releasing a gem
  def pre_release
    raise "Repo not clean" if !`git status -s`.empty?
    puts "Sync description from readme to gemspec..."
    sync_description(:commit=>true)

    puts "Check deps.rip..."
    deps_rip
    deps_rip :dev=>true
    system "git commit -m 'Updated deps.rip' ." if !`git status -s`.empty?

    puts "Checking gemspec files that haven't been committed..."
    if !(files = manifest).empty?
      raise files.inspect
    end
    puts "Checking committed files that aren't in gemspec..."
    if !(files = manifest(:reverse=>true)).empty?
      raise files.inspect
    end

    if File.directory?('test')
      puts "Run tests..."
      test_all
    end
  end

  # @options :yardoc=>:boolean
  # Tasks to perform after a release
  def post_release(options={})
    if File.exists?('website')
      if File.exists?('website/doc')
        if options[:yardoc] || File.exists?('website/doc/method_list.html')
          puts "Generating yardoc documentation..."
          doc :yardoc=>true
        else
          puts "Generating rdoc documentation..."
          doc
        end
      end

      puts "Creating website..."
      website
      puts "Publishing website..."
      publish
    end
  end

  # @options :commit=>:boolean
  # Syncs gemspec description to readme's desc
  def sync_description(options={})
    desc = readme_description
    return if current_gemspec.description == desc
    desc = desc.include?('"') ? "%[#{desc}]" : %["#{desc}"]
    z.edit_gemspec('description', desc, :replace=>true)
    system 'rake -s gemspec'
    if $?.success?
      system "git commit 'Updated gemspec description from readme' ." if options[:commit]
    else
      raise "Failed to create valid gemspec with new description"
    end
  end

  #List of ruby versions
  def rubies
    rvm_ruby = File.expand_path "~/.rvm/bin/ruby-"
    { "system"=>'/usr/bin/ruby', '1.9.2'=>"#{rvm_ruby}1.9.2-preview1", '1.8.7'=>"#{rvm_ruby}1.8.7-p249" }
  end

  # Only works in system ruby
  # @desc Dumps list of gems across ruby versions
  def gem_dump
    gem_path = File.expand_path "~/.rvm/rubies/ruby-%s/bin/gem"
    rubies.map {|version,path|
      path = path[/\d\.\d\.\d/] ? gem_path % path[/\d\.\d\.\d-[^\/]+$/] : '/usr/bin/gem'
      body = `#{path} list`
      File.open(File.expand_path("~/.gems/#{version}"), 'w') {|f| f.write body }
      [version, body.split("\n").size]
    }
  end

  # @options :except=>:string
  # Run tests on multiple versions of ruby
  def test_all(options={})
    bacon = File.expand_path '~/.rip/test/bin/bacon'
    test_rubies = rubies
    test_rubies = test_rubies.select {|k,v| !k[/#{options[:except]}/] } if options[:except]
    test_rubies.all? {|k,v|
      puts "Running tests with ruby #{k}"
      cmd = "#{v} #{bacon} -q -I~/.rip/test/lib -Ilib -I. test/*_test.rb"
      system cmd
      $?.success?
    }
  end

  # Publish pages in website directory to gh-pages branch
  def publish
    raise "Can't publish if doc/ exists" if File.exists?('doc')
    `git checkout gh-pages`
    FileUtils.cp_r 'website/.', '.'
    `git add doc index.html`
    system "git commit -am 'Updated files.'"
    system "git push origin gh-pages"
    `git checkout master`
    "Published website."
  end

  # @options :yardoc=>:boolean
  # Create documentation with rdoc or yard
  def doc(*doc_opts)
   options = doc_opts[-1].is_a?(Hash) ? doc_opts.pop : {}
   directory = File.exists?("website") ? 'website/doc' : 'doc'
   FileUtils.rm_r(directory) if File.exists?(directory)
   args = if options[:yardoc]
     args = %w{yardoc --no-private}
     if !(files = Dir['{CHANGELOG.rdoc,LICENSE.txt}']).empty?
       args += ['--files', files.join(',')]
      end
     args
   else
     %w{rdoc} # -T hanna}
   end
   args += (current_gemspec.rdoc_options rescue [])
   args += ['-o', directory]
   args += doc_opts
   args += Dir['lib/**/*.rb']
   ["README.rdoc", "LICENSE.TXT"].each {|e| args << e if File.exists?(e) } unless options[:yardoc]
   system(*args)
   directory + '/index.html'
  end
end
