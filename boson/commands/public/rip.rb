# Commands to enhance rip2
module RipLib
  def self.included(mod)
    require 'rip'
  end

  # @options :local=>:boolean, :env=>{:type=>:string, :values=>%w{test db rdf base irbfiles misc web},
  #  :enum=>false }, :version=>:string
  # @config :alias=>'rip'
  # Enhance rip install
  def rip_install(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    args = [ "file://"+File.expand_path('.') ] if options[:local]
    ENV['RIPENV'] = options[:env] if options[:env]
    args.each {|e|
      sargs = ['rip','install', e]
      sargs << options[:version] if options[:version]
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

  # @options :local=>:boolean, :env=>{:type=>:string, :values=>%w{test db rdf base irbfiles misc web},
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
    find_package(pkg)
    dir = `rip info #{pkg} path`.chomp
    if !dir.empty?
      Dir.chdir dir
      rake 'test'
    end
    dir
  end

  # Get rip-info across any env
  def rip_info(pkg)
    find_package(pkg) && system('rip','info', pkg)
  end

  # rip-readme across any env
  def rip_readme(pkg)
    find_package(pkg) && system('rip','readme', pkg)
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
  end

  private
  def rip_env_status(env, active_envs)
    env == Rip.env ? "* " :
      active_envs.any? {|e| e == "#{ENV['RIPDIR']}/#{env}/lib" } ?  "+ " : "  "
  end
end
