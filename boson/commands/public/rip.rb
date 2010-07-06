# Commands to enhance rip2
module RipLib
  def self.included(mod)
    require 'rip'
  end

  # @options :local=>:boolean, :env=>{:type=>:string, :values=>%w{test db rdf base irb misc web},
  #  :enum=>false }, :version=>:string, :debug=>:boolean, :force=>:boolean
  # @config :alias=>'rip'
  # Enhance rip install
  def rip_install(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    args = [ "file://"+File.expand_path('.') ] if options[:local]
    ENV['RIPENV'] = options[:env] if options[:env]
    args.each {|e|
      sargs = ['rip','install', e]
      sargs << options[:version] if options[:version]
      sargs.insert(2, '-d') if options[:debug]
      sargs.insert(2, '-f') if options[:force]
      system *sargs
    }
  end

  # @options :status=>:boolean, :version=>:boolean, :dir=>:boolean
  # @config :alias=>'rl'
  # List rip packages
  def rip_list(options={})
    setup_helpers

    active = ENV['RUBYLIB'].to_s.split(":")
    Rip.envs.inject([]) {|t,e|
      ENV['RIPENV'] = e
      env = options[:status] ? rip_env_status(e, active)+e : e
      if options[:version] || options[:dir]
        Rip::Helpers.rip(:installed).each {|dir|
          pkg = Rip::Helpers.metadata(dir)
          hash = {:env=>env, :package=>pkg.name, :version=>pkg.version}
          t << (options[:dir] ? hash.merge(:dir=>dir.chomp) : hash)
        }
        t
      else
        t << {:env=>env, :packages=>current_packages}
      end
    }
  end

  # @options :local=>:boolean, :env=>{:type=>:string, :values=>%w{test db rdf base irb misc web},
  #  :enum=>false }, :recursive=>:boolean
  # Wrapper around rip uninstall
  def rip_uninstall(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    args += package_recursive_deps(args[0], :array=>true) if options[:recursive]
    ENV['RIPENV'] = options[:env] if options[:env]
    if options[:recursive] && find_package(args[0])
      options[:env] = ENV['RIPENV']
    end
    args.each {|e|
      find_package(e) unless options[:env]
      system 'rip','uninstall', e
    }
  end

  # @options :verbose=>:boolean, :rebuild=>:boolean, :yard_options=>:hash
  # Builds yard doc as needed and returns doc path
  def rip_yard(pkg, options={})
    if (pkg_dir = find_package(pkg))
      if options[:yard_options]
        options[:yard_options] = options[:yard_options].map {|k,v|
          dash = k.size > 1 ? "--" : "-"
          [dash + k, v]
        }.flatten
      end
      build_yard_doc(pkg, pkg_dir, options)
    end
  end

  # @options :verbose=>:boolean, :rebuild=>:boolean, :package=>:string
  # Builds yard doc as needed and runs yri for current package
  def rip_yri(query, options={})
    if options[:package] && (pkg_dir = find_package(options[:package]))
      build_yard_doc(options[:package], pkg_dir, options.merge(:yard_options=>['-n']))
    end
    dirs = Dir.glob(File.expand_path("~/.rip/.yard/*/.yardoc"))
    dirs = dirs.select {|e| e[/#{options[:package]}/] } if options[:package]
    results = yri query, dirs, options
    results = menu(results) if results.size > 1
    Array(results).each {|e| system('yri', '-b', @yardoc, e) }
    nil
  end

  # Queries a set of .yardocs and returns first matches
  def yri(query, yardocs=['.yardoc'], options={})
    require 'yard'
    yardocs.each {|e|
      @yardoc = e
      puts "Searching #{e}..." if options[:verbose]
      YARD::Registry.load(e)
      YARD::Registry.load_all
      results = YARD::Registry.all
      results -= YARD::Registry.all(:method) if query[/^[A-Z][^#\.]+$/]
      results = results.select {|e| e.path[/#{query}/] }.map {|e| e.path }
      results = [query] if results.include?(query)
      return results if results.size > 0
    }
    []
  end

  # Restores all rip envs to state saved by rip_dump directory
  def rip_restore(dir='~/.rip_envs')
    Dir.glob(File.expand_path(dir)+"/*").each {|f|
      ENV['RIPENV'] = File.basename(f).sub('.rip', '')
      system 'rip','install', '-o', f
    }
  end

  # @options :diff=>:boolean, :dir=>'~/.rip_envs'
  # Backs up all rip envs into a directory
  def rip_dump(options={})
    dir = File.expand_path(options[:dir])
    original_dir = dir.dup
    dir = '/tmp/rip_dump_diff' if options[:diff]
    require 'fileutils'
    FileUtils.rm_f Dir.glob(dir+"/*")
    FileUtils.mkdir_p dir

    envs = Rip.envs.each {|e|
      ENV['RIPENV'] = e
      File.open("#{dir}/#{e}.rip", 'w') {|f|
        f.write `rip list -p`
      }
    }
    options[:diff] ? system("diff", "-r", original_dir, dir) : envs
  end

  # @options :dir=>:boolean, :strict=>:boolean, :exceptions=>:boolean
  # Prints dirty files in lib/ of rip envs i.e. ones that don't match any package namespace
  def rip_dirty_lib(options={})
    list = rip_list
    list.map {|hash|
      lib_dir = ENV['RIPDIR']+"/#{hash[:env]}/lib/"
      env_files = Dir.glob(lib_dir+"*").map {|e| File.basename(e) }
      filter = options[:strict] ? '^%s(\.\w+$|$)' : '^%s'
      env_files = env_files.reject {|f|
        hash[:packages].any? {|e|
          namespace = e[/\w+/]
          f[Regexp.new(filter % namespace)] ||
            (options[:exceptions] ? dirty_lib_exception(f, e) : false)
        }
      }
      if options[:dir]
        env_files.map! {|e| File.directory?(lib_dir+e) ?
          (e+"("+Dir.glob(lib_dir+e+"/**/*.*").size.to_s+")") : e
        }
      end
      [hash[:env], env_files]
    }
  end

  # @options :verbose=>:boolean
  # Verifies that packages in envs load. Returns ones that fail with LoadError
  def rip_verify(*envs)
    options = envs[-1].is_a?(Hash) ? envs.pop : {}
    envs = Rip.envs if envs.empty?
    failed = {}
    exceptions = %w{mynyml ssoroka matthew ruby-}
    envs.each {|e|
      ENV['RIPENV'] = e
      ENV['RUBYLIB'] += ":#{ENV['RIPDIR']}/#{e}/lib"
      puts "Verifying env #{e}"
      current_packages.each {|f|
        begin
          require 'rdf' if f[/rdf/]
          f2 = f[Regexp.union(*exceptions)] ? f.sub(/^\w+-/, '') : f.sub('-', '/')
          puts "Requiring '#{f2}'" if options[:verbose]
          require f2
        rescue LoadError
          (failed[e] ||= []) << f
        end
      }
    }
    failed
  end

  # Runs `rake test in rip package directory across any env
  def rip_test(pkg)
    if (dir = find_package(pkg))
      Dir.chdir dir
      exec 'rake', 'test'
    end
  end

  # Execute a git command on a package
  def rip_git(pkg, *args)
    if (dir = find_package(pkg))
      Dir.chdir dir
      exec 'git', *args
    end
  end

  # Get rip-info across any env
  def rip_info(*args)
    find_package(args[0]) && exec('rip','info', *args)
  end

  # rip-readme across any env
  def rip_readme(pkg)
    find_package(pkg) && exec('rip','readme', pkg)
  end

  # @options :file=>{:default=>'gemspec', :values=>%w{gemspec changelog rakefile version}, :enum=>false}
  # Displays top level file from a rip package
  def rip_file(pkg, options={})
    globs = {'gemspec'=>'{gemspec,*.gemspec}', 'changelog'=>'{CHANGELOG,HISTORY}'}
    file_glob = globs[options[:file]] || options[:file]
    (dir = find_package(pkg)) && (file = Dir.glob("#{dir}/*#{file_glob}*", File::FNM_CASEFOLD)[0]) &&
      File.file?(file) ? File.read(file) : "No file '#{options[:file]}'"
  end

  # @options :verbose=>:boolean, :recursive=>true
  # Prints dependencies for package in any env
  def rip_deps(pkg, options={})
    return package_deps(pkg) if !options[:recursive]
    nodes = package_recursive_deps(pkg, options)
    render nodes, :class=>:tree, :type=>:directory
  end

  # Moves env to a new name
  def rip_mv(old, new)
    system 'rip', 'env', old
    system 'rip', 'env', '-b', new
    system 'rip', 'env', '-d', old
  end

  # Finds rip package and returns package directory name
  def find_package(pkg)
    setup_helpers

    Rip.envs.each {|env|
      ENV['RIPENV'] = env
      Rip::Helpers.rip(:installed).each {|curr|
        return curr.chomp if curr[/\/#{pkg}-\w{32}/]
      }
    }
    nil
  end

  private
  def build_yard_doc(pkg, pkg_dir, options)
    yard_dir = File.expand_path("~/.rip/.yard") + "/" + File.basename(pkg_dir)
    require 'fileutils'
    FileUtils.mkdir_p yard_dir
    Dir.chdir yard_dir
    puts "First time building YARD doc for '#{pkg}'..." if !File.exists?('doc')
    if !File.exists?('doc') || options[:rebuild]
      cmd = ['yardoc', '--no-private']
      cmd << '-q' unless options[:verbose]
      cmd += ['-c', '.yardoc']  unless options[:rebuild]
      cmd += options[:yard_options] if options[:yard_options]
      readme = Dir[pkg_dir + '/README*'][0].to_s
      cmd += ['-m', 'markdown'] if readme[/README\.m/]
      cmd += ['-m', 'textile'] if readme[/README\.t/]
      cmd += [pkg_dir + "/lib/**/*.rb", '-', pkg_dir+'/README*']
      puts "Building YARD documentation with: " +cmd.join(' ') if options[:verbose]
      system *cmd
    end
    yard_dir + "/doc/index.html"
  end

  def dirty_lib_exception(path, namespace)
    exceptions = %w{rubygems rubygems_plugin.rb autotest tasks}
    namespace_exceptions = {'rdf'=>'^df', 'rspec'=>'^spec', 'json_pure'=>'^json', 'ssoroka-ansi'=>'^ansi', 'googlebase'=>'google',
      'activesupport'=>'active_support', 'mynyml-every'=>'every', 'ruby-gmail'=>'gmail', 'matthew-method_lister'=>'method_lister',
      'git-hub'=>'hub'}
    exceptions.include?(path) || ((exc = namespace_exceptions[namespace]) && path[/#{exc}/])
  end

  def setup_helpers
    @setup_helpers ||= begin
      require 'rip/helpers'
      Rip::Helpers.extend Rip::Helpers
      true
    end
  end

  def current_packages
    setup_helpers
    Rip::Helpers.rip(:installed).map {|dir| dir[/\/([^\/]+)-\w{32}/, 1] }
  end

  def all_packages
    @packages ||= rip_list(:dir=>true).map {|e| e[:dir] }
  end

  def package_recursive_deps(pkg, options={})
    @nodes, @options = [], options
    build_recursive_deps(pkg, 0)
    options[:array] ? @nodes.map {|e| e[:value][/\w+/] } - [pkg] : @nodes
  end

  def build_recursive_deps(pkg, index)
    p [pkg, index] if @options[:verbose]
    @nodes << {:level=>index, :value=>pkg}
    package_deps(pkg[/\w+/]).each {|e|
      build_recursive_deps(e, index + 1)
    }
  end

  def package_deps(pkg)
    (pkg_dir = all_packages.find {|e| e[/\/#{pkg}-\w{32}/] }) ?
      (File.read("#{pkg_dir}/deps.rip").split("\n") rescue []) : []
  end

  def rip_env_status(env, active_envs)
    env == Rip.env ? "* " :
      active_envs.any? {|e| e == "#{ENV['RIPDIR']}/#{env}/lib" } ?  "+ " : "  "
  end
end
