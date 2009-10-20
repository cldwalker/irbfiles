module RubyCore
  def self.config
    commands = %w{cd Dir.chdir pwd Dir.pwd x Kernel.exit sy Kernel.system yl YAML.load_file}
    {:class_commands=>Hash[*commands] }
  end
end