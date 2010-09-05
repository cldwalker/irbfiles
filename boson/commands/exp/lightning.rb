# Commands mainly for use while developing Lightning
module Dev
  def self.included(mod)
    require 'lightning'
  end

  # @config :alias=>'lb'
  # Build's local version using bin/lightning-build
  def dev_build(file=nil)
    system("bin/lightning build #{file}")
    if file
      file_string = File.read(file)
      file_string.sub!(/[^#]LBIN_PATH/, "\n#LBIN_PATH")
      file_string.sub!('#LBIN_PATH', 'LBIN_PATH')
      File.open(file, 'w') {|f| f.write file_string }
    end
  end

  # @render_options :fields=>[:name, :alias_or_name, :globs]
  # @config :alias=>'b'
  # Lists bolts
  def bolts
    Lightning.functions
    Lightning.bolts.values
  end

  # @render_options :fields=>{:default=>%w{name shell_command bolt globs}, :values=>%w{name shell_command bolt globs aliases}},
  #  :filters=>{:default=>{'aliases'=>:inspect, 'bolt'=>:alias_or_name}}
  # @config :alias=>'bcom'
  # Lists commands
  def lightning_functions
    Lightning.functions.values
  end

  # @render_options {}
  # List generators
  def generators
    Lightning::Generator.generators
  end
end
