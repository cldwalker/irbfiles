module RubyCore
  def self.config
    commands = %w{cd Dir.chdir pwd Dir.pwd x Kernel.exit sy Kernel.system yl YAML.load_file}
    command_desc = {
      'cd'=>{:desc=>'Change directory'},
      'pwd'=>{:desc=>'Print current directory'},
      'x'=>{:desc=>'Exit shell'},
      'sy'=>{:desc=>'Execute system command'},
      'yl'=>{:desc=>'Load yaml file'}
    }
    {:class_commands=>Hash[*commands], :commands=>command_desc}
  end
end