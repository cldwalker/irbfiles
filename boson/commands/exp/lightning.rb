# Commands mainly for use while developing Lightning
module Dev
  def self.included(mod)
    require 'local_gem'
    LocalGem.local_require 'lightning'
  rescue LoadError
    require 'lightning'
  end

  # @config :alias=>'lb'
  # Build's local version using bin/lightning-build
  def dev_build(file=nil)
    system("bin/lightning-build #{file}")
    if file
      file_string = File.read(file)
      file_string.sub!(/[^#]LBIN_PATH/, "\n#LBIN_PATH")
      file_string.sub!('#LBIN_PATH', 'LBIN_PATH')
      File.open(file, 'w') {|f| f.write file_string }
    end
  end

  # @config :alias=>'lc'
  # Shortcut to bin/lightning-complete
  def complete(*args)
    system("bin/lightning-complete", *args)
  end

  # @config :alias=>'lt'
  # Shortcut to bin/lightning-translate
  def translate(*args)
    system("bin/lightning-translate", *args)
  end

  # @render_options :fields=>[:name, :alias_or_name, :paths]
  # @config :alias=>'b'
  # Lists bolts
  def bolts
    Lightning.setup
    Lightning.bolts.values
  end

  # @render_options :fields=>{:default=>%w{name shell_command bolt paths}, :values=>%w{name shell_command bolt paths aliases}},
  #  :filters=>{:default=>{'aliases'=>:inspect, 'bolt'=>:alias_or_name}}
  # @config :alias=>'bcom'
  # Lists commands
  def bolt_commands
    Lightning.setup
    Lightning.commands.values
  end
end