# Commands to enhance rip2
module RipLib
  def self.included(mod)
    require 'rip'
  end

  # @options :local=>:boolean, :env=>{:type=>:string, :values=>%w{test db rdf base irbfiles misc web},
  #  :enum=>false }, :version=>:string
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
  # List rip packages
  def rip_list(options={})
    require 'rip/helpers'
    Rip::Helpers.extend Rip::Helpers
    ENV['RUBYLIB']

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
    args.each {|e| system 'rip','uninstall', e }
  end

  private
  def rip_env_status(env, active_envs)
    env == Rip.env ? "* " :
      active_envs.any? {|e| e == "#{ENV['RIPDIR']}/#{env}/lib" } ?  "+ " : "  "
  end
end
