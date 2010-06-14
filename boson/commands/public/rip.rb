# Commands to enhance rip2
module RipLib
  def self.included(mod)
    require 'rip'
  end

  # @options :local=>:boolean, :env=>{:type=>:string, :values=>%w{test db rdf base irb misc web},
  #  :enum=>false }, :version=>:string, :debug=>:boolean
  # @config :alias=>'rip'
  # Enhance rip install
  def rip_install(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    args = [ "file://"+File.expand_path('.') ] if options[:local]
    ENV['RIPENV'] = options[:env] if options[:env]
    args.each {|e|
      sargs = ['rip','install', e]
      sargs << options[:version] if options[:version]
      sargs.insert(1, '-d') if options[:debug]
      system *sargs
    }
  end

  # @options :status=>:boolean, :version=>:boolean, :dir=>:boolean
  # @config :alias=>'rl'
  # List rip packages
  def rip_list(options={})
    require 'rip/helpers'
    Rip::Helpers.extend Rip::Helpers

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
        pkg = Rip::Helpers.rip(:installed).map {|dir| dir[/\/([^\/]+)-\w{32}/, 1] }
        t << {:env=>env, :packages=>pkg}
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

  # Runs `rake test in rip package directory across any env
  def rip_test(pkg)
    if (dir = find_package(pkg))
      Dir.chdir dir
      exec 'rake', 'test'
    end
  end

  # A package's git history
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

  # Finds rip package and returns its env name
  def find_package(pkg)
    require 'rip/helpers'
    Rip::Helpers.extend Rip::Helpers

    Rip.envs.each {|env|
      ENV['RIPENV'] = env
      Rip::Helpers.rip(:installed).each {|curr|
        return curr.chomp if curr[/\/#{pkg}-\w{32}/]
      }
    }
    nil
  end

  private
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

  def captured_rip_info(*args)
    find_package(args[0]) && `rip info #{args.join(' ')}`.chomp
  end

  def rip_env_status(env, active_envs)
    env == Rip.env ? "* " :
      active_envs.any? {|e| e == "#{ENV['RIPDIR']}/#{env}/lib" } ?  "+ " : "  "
  end
end
