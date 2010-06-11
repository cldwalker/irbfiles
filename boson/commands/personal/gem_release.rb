module GemRelease
  # Run tests on multiple versions of ruby
  def test_all
    rvm_ruby = File.expand_path "~/.rvm/bin/ruby-"
    rubies = { "system"=>'/usr/bin/ruby', '1.9.2'=>"#{rvm_ruby}1.9.2-preview1", '1.8.7'=>"#{rvm_ruby}1.8.7-p249" }
    bacon = File.expand_path '~/.rip/test/bin/bacon'
    rubies.all? {|k,v|
      puts "Running tests with ruby #{k}"
      cmd = "#{v} #{bacon} -q -I~/.rip/test/lib -Ilib -I. test/*_test.rb"
      system cmd
      $?.success?
    }
  end

  # Publish pages in website directory to gh-pages branch
  def publish
    `git checkout gh-pages`
    FileUtils.cp_r 'website/.', '.'
    `git add doc index.html`
    system "git commit -am 'Updated files.'"
    system "git push origin gh-pages"
    `git checkout master`
    "Published website."
  end

  # @options :yardoc=>:boolean
  # Create rdoc with hanna
  def rdoc(*doc_opts)
   options = doc_opts[-1].is_a?(Hash) ? doc_opts.pop : {}
   directory = File.exists?("website") ? 'website/doc' : 'doc'
   FileUtils.rm_r(directory) if File.exists?(directory)
   args = options[:yardoc] ? %w{yardoc --no-private} : %w{rdoc --inline-source --format=html -T hanna}
   args += ['-o', directory]
   args += doc_opts
   args += Dir['lib/**/*.rb']
   ["README.rdoc", "LICENSE.TXT"].each {|e| args << e if File.exists?(e) }
   system(*args)
   directory + '/index.html'
  end
end
