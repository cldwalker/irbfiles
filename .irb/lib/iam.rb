require 'yaml'
module Iam
  module Libraries; end
  class <<self
    attr_accessor :base_dir, :libraries, :base_object
    def register(*args)
      options = args[-1].is_a?(Hash) ? args.pop : {}
      @libraries ||= []
      @base_object = options[:with] || @base_object || Object.new
      @base_object.send :extend, Iam::Libraries
      @base_dir = options[:base_dir] || "#{ENV['HOME']}/.irb"
      args.each {|e| load_library(e, options) }
    end

    def load_library(library, options={})
      begin
        if File.exists?(File.join(base_dir, "#{library}.rb"))
          load File.join(base_dir, "#{library}.rb")
          @libraries << library
          puts "Loaded library file '#{library}'" if $DEBUG
        #td: eval in base_object without having to intrude with extend
        elsif base_object.respond_to?(library)
          base_object.send(library)
          @libraries << library
          puts "Loaded library method '#{library}'" if $DEBUG
        else
          puts "Library '#{library}' not found"
        end
      rescue LoadError
        puts "Failed to load '#{library}'"
      rescue Exception
        puts "Failed to load '#{library}'"
        puts "Reason: #{$!}"
      end
    end
  end
  
  def libs
    require 'hirb'
    puts Hirb::Helpers::Table.render(Iam.libraries.map {|e| [e] })
  end
end
__END__
def create_commands(name, options={})
  if options[:type] == :gem
    require name
    (options[:methods] || []).map {|e|
      create_command(:name=>e)
    }
  else
    name.instance_methods.map {|e|
      create_command(:name=>e)
    }
  end
end

def create_command(command)
  {:name=>command[:name], :description=>(config['commands'][command[:name]]['description'] rescue nil)}
end

  #def list
    #print_commands Iam.commands
  #end
  #
  #def search(query='')
    #print_commands Iam.commands.select {|e| e[:name] =~ /#{query}/}
  #end
#
  #private
  #def print_commands(commands)
    #puts Hirb::Helpers::Table.render(commands, :fields=>[:name, :description])
  #end

    #def config(reload=false)
      #@config = YAML::load_file('commands.yml') if reload || @config.nil?
      #@config
    #end
#
    #def commands
      #(@commands ||= []) + create_class_commands(Iam)
    #end
    #
    #def register2(*args)
      #@commands ||= []
      #options = args[-1].is_a?(Hash) ? args.pop : {}
      #args.each {|e| @commands += create_commands(e, options)}
    #end