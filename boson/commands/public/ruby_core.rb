module RubyCore
  def self.config
    commands = %w{cd Dir.chdir pwd Dir.pwd x Kernel.exit sy Kernel.system yl YAML.load_file}
    command_desc = {
      'cd'=>{:description=>'Change directory'},
      'pwd'=>{:description=>'Print current directory'},
      'x'=>{:description=>'Exit shell'},
      'sy'=>{:description=>'Execute system command'},
      'yl'=>{:description=>'Load yaml file'}
    }
    {:class_commands=>Hash[*commands], :commands=>command_desc}
  end
end