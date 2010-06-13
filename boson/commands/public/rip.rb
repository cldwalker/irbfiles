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

  # @render_options :change_fields=>['env', 'packages']
  # @options :status=>:boolean
  # @config :alias=>'rl'
  # List rip packages
  def rip_list(options={})
    require 'rip/helpers'
    Rip::Helpers.extend Rip::Helpers

    active = ENV['RUBYLIB'].to_s.split(":")
    Rip.envs.inject({}) {|t,e|
      ENV['RIPENV'] = e
      key = options[:status] ? rip_env_status(e, active)+e : e
      t[key] = Rip::Helpers.rip("installed").map {|e| Rip::Helpers::metadata(e).name }
      t
    }
  end

  # @options :local=>:boolean, :env=>{:type=>:string, :values=>%w{test db rdf base irb misc web},
  #  :enum=>false }
  # Wrapper around rip uninstall
  def rip_uninstall(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    ENV['RIPENV'] = options[:env] if options[:env]
    args.each {|e|
      find_package(e) unless options[:env]
      system 'rip','uninstall', e
    }
  end

  # Runs `rake test in rip package directory across any env
  def rip_test(pkg)
    if (dir = captured_rip_info(pkg, 'path'))
      Dir.chdir dir
      rake 'test'
      true
    end
  end

  # Get rip-info across any env
  def rip_info(*args)
    find_package(args[0]) && system('rip','info', *args)
  end

  # rip-readme across any env
  def rip_readme(pkg)
    find_package(pkg) && system('rip','readme', pkg)
  end

  # @options :file=>{:default=>'gemspec', :values=>%w{gemspec changelog rakefile version}, :enum=>false}
  # Displays top level file from a rip package
  def rip_file(pkg, options={})
    globs = {'gemspec'=>'{gemspec,*.gemspec}', 'changelog'=>'{CHANGELOG,HISTORY}'}
    file_glob = globs[options[:file]] || options[:file]
    (dir = captured_rip_info(pkg, 'path')) && (file = Dir.glob("#{dir}/*#{file_glob}*", File::FNM_CASEFOLD)[0]) &&
      File.file?(file) ? File.read(file) : "No file '#{options[:file]}'"
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
      Rip::Helpers.rip("installed").each {|curr|
        return env if Rip::Helpers::metadata(curr).name == pkg
      }
    }
    nil
  end

  private
  def captured_rip_info(*args)
    find_package(args[0]) && `rip info #{args.join(' ')}`.chomp
  end

  def rip_env_status(env, active_envs)
    env == Rip.env ? "* " :
      active_envs.any? {|e| e == "#{ENV['RIPDIR']}/#{env}/lib" } ?  "+ " : "  "
  end
end
