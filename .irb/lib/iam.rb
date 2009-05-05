require 'yaml'
require 'hirb'
require 'alias'
$:.unshift File.dirname(__FILE__)
require 'iam/commands'
require 'iam/util'

module Iam
  module Libraries; end
  class <<self
    attr_reader :base_dir, :libraries, :base_object, :commands
    def config(reload=false)
      if reload || @config.nil?
        @config = YAML::load_file(base_dir + '/iam.yml') rescue {:commands=>{}, :libraries=>{}}
      end
      @config
    end

    # can only be run once b/c of alias and extend
    def register(*args)
      options = args[-1].is_a?(Hash) ? args.pop : {}
      @libraries ||= []
      @commands ||= []
      @base_object = options[:with] || @base_object || Object.new
      @base_object.send :extend, Iam::Libraries
      @base_dir = options[:base_dir] || "#{ENV['HOME']}/.irb"
      args.each {|e| load_library(e, options) }
      create_aliases
    end

    def create_aliases
      aliases_hash = {}
      Iam.commands.each do |e|
        if e[:alias]
          aliases_hash[e[:lib]] ||= {}
          aliases_hash[e[:lib]][e[:name]] = e[:alias]
        end
      end
      Alias.init {|c| c.instance_method = aliases_hash}
    end

    def load_library(library, options={})
      begin
        if library.is_a?(Module) || File.exists?(File.join(base_dir, "#{library}.rb"))
          if File.exists?(File.join(base_dir, "#{library}.rb"))
            load File.join(base_dir, "#{library}.rb") 
            unless library = Util.constantize(library)
              puts "No module found for library #{library}"
              return
            end
          end
          base_object.extend(library)
          @libraries << create_library(library.to_s, :module, :module=>library)
        elsif File.exists?(File.join(base_dir, "#{library}.rb"))
          load File.join(base_dir, "#{library}.rb")
          @libraries << create_library(library, :file)
        #td: eval in base_object without having to intrude with extend
        elsif base_object.respond_to?(library)
          base_object.send(library)
          @libraries << create_library(library, :method)
        else
          puts "Library '#{library}' not found"
        end
      rescue LoadError
        puts "Failed to load '#{library}'"
      rescue Exception
        puts "Failed to load '#{library}'"
        puts "Reason: #{$!}"
        puts caller.slice(0,3).join("\n")
      end
    end

    def create_library(name, library_type, lib_hash={})
      library_obj = (config[:libraries][name.to_s] || {}).merge(lib_hash).merge({:name=>name, :type=>library_type})
      set_library_commands(library_obj)
      library_obj[:commands].each {|e| @commands << create_command(e, name)}
      puts "Loaded #{library_type} library '#{name}'" if $DEBUG
      library_obj
    end

    def set_library_commands(library_obj)
      library_obj[:commands] ||= begin
        if library_obj[:module]
          aliases = library_obj[:module].instance_methods.map {|e|
            config[:commands][e][:alias] rescue nil
          }.compact
          library_obj[:module].instance_methods - aliases
        else
          []
        end
      end
    end

    def create_command(name, library=nil)
      (config[:commands][name] || {}).merge({:name=>name, :lib=>library})
    end
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

#def search(query='')
  #print_commands Iam.commands.select {|e| e[:name] =~ /#{query}/}
#end

#def print_commands(commands)
  #puts Hirb::Helpers::Table.render(commands, :fields=>[:name, :description])
#end