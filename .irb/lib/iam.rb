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

    def init(options={})
      @libraries ||= []
      @commands ||= []
      @base_dir = options[:base_dir] || (File.exists?("#{ENV['HOME']}/.irb") ? "#{ENV['HOME']}/.irb" : '.irb')
      $:.unshift @base_dir unless $:.include? File.expand_path(@base_dir)
    end

    # can only be run once b/c of alias and extend
    def register(*args)
      options = args[-1].is_a?(Hash) ? args.pop : {}
      init(options)
      @base_object = options[:with] || @base_object || Object.new
      @base_object.send :extend, Iam::Libraries
      create_libraries(args, options)
      create_aliases
    end

    def create_libraries(libraries, options={})
      libraries.each {|e|
        create_and_load_library(e, options)
      }
      library_names = Iam.libraries.map {|e| e[:name]}
      config[:libraries].each do |name, lib|
        unless library_names.include?(name)
          @libraries << create_library(name)
        end
      end
    end

    def create_aliases
      aliases_hash = {}
      Iam.commands.each do |e|
        if e[:alias]
          if ((lib = Iam.libraries.detect {|l| l[:name] == e[:lib]}) && !lib[:module]) || !lib
            puts "No lib module for #{e[:name]} when aliasing"
            next
          end
          aliases_hash[lib[:module].to_s] ||= {}
          aliases_hash[lib[:module].to_s][e[:name]] = e[:alias]
        end
      end
      Alias.init {|c| c.instance_method = aliases_hash}
    end

    def create_and_load_library(*args)
      if (lib = load_library(*args)) && lib.is_a?(Hash)
        @libraries << lib
      end
    end

    def create_or_update_library(*args)
      if (lib = load_library(*args)) && lib.is_a?(Hash)
        if (existing_lib = Iam.libraries.find {|e| e[:name] == lib[:name]})
          existing_lib.merge!(lib)
        else
          @libraries << lib
        end
        puts "Loaded library #{lib[:name]}"
      end
    end

    def load_library(library, options={})
      begin
        if (library.is_a?(Symbol) || library.is_a?(String)) && base_object.respond_to?(library)
          base_object.send(library)
          return create_loaded_library(library, :method)
        end

        if library.is_a?(Module) || (module_library = Util.constantize(library))
          library = module_library if module_library
          library.send(:init) if library.respond_to?(:init)
          base_object.extend(library)
          create_loaded_library(Util.underscore(library), :module, :module=>library)
        #td: eval in base_object without having to intrude with extend
        else
          #try gem
          begin
            require "libraries/#{library}"
            object_methods = Object.methods
            if (gem_module = Util.constantize("iam/libraries/#{library}"))
              gem_module.send(:init) if gem_module.respond_to?(:init)
              base_object.extend(gem_module)
              library_hash = {:module=>gem_module}
            else
              require library.to_s
              library_hash = {}
            end
            return create_loaded_library(library, :gem, library_hash.merge(:commands=>(Object.methods - object_methods)))
          rescue
            puts "Failed to load gem library"
            puts caller.slice(0,5).join("\n")
          end
          puts "Library '#{library}' not found"
        end
      rescue LoadError
        puts "Failed to load '#{library}'"
      rescue Exception
        puts "Failed to load '#{library}'"
        puts "Reason: #{$!}"
        puts caller.slice(0,5).join("\n")
      end
    end

    def create_loaded_library(name, library_type, lib_hash={})
      create_library(name, library_type, lib_hash.merge(:loaded=>true))
    end

    def create_library(name, library_type=nil, lib_hash={})
      library_obj = {:loaded=>false, :name=>name.to_s}.merge(config[:libraries][name.to_s] || {}).merge(lib_hash)
      library_obj[:type] = library_type if library_type
      set_library_commands(library_obj)
      if library_obj[:loaded]
        library_obj[:commands].each {|e| @commands << create_command(e, name)}
      end
      puts "Loaded #{library_type} library '#{name}'" if $DEBUG
      library_obj
    end

    def set_library_commands(library_obj)
      library_obj[:commands] ||= []
      if library_obj[:module]
        aliases = library_obj[:module].instance_methods.map {|e|
          config[:commands][e][:alias] rescue nil
        }.compact
        library_obj[:commands] += (library_obj[:module].instance_methods - aliases)
      end
    end

    def create_command(name, library=nil)
      (config[:commands][name] || {}).merge({:name=>name, :lib=>library.to_s})
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