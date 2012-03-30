module GemRelease
  def self.config
    {:dependencies=>['public/release', 'exp/paz', 'exp/readme', 'personal/system_misc']}
  end

  # @options :test => true, :sync => true
  # Checklist to run before releasing a gem
  def pre_release(options={})
    raise "Repo not clean" if !`git status -s`.empty?
    puts "Sync description from readme to gemspec..."
    sync_description(:commit=>true) if options[:sync]

    puts "Check deps.rip..."
    deps_rip
    deps_rip :dev=>true
    system "git commit -m 'Update deps.rip' ." if !`git status -s`.empty?

    puts "Check backup files to delete..."
    delete_backups unless Dir.glob('**/*~', File::FNM_DOTMATCH).empty?

    puts "Checking gemspec files that haven't been committed..."
    if !(files = manifest).empty?
      raise files.inspect
    end
    puts "Checking committed files that aren't in gemspec..."
    if !(files = manifest(:reverse=>true)).empty?
      raise files.inspect
    end

    if options[:test] && File.directory?('test') || File.directory?('spec')
      system('rbenv travis')
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
