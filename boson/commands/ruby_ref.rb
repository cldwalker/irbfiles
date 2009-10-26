# Gives useful info about current environment
module RubyRef
  # @render_options :headers=>{:default=>{0=>"variable",1=>"value"}}
  # Prints global variables and their values
  def global_var
    global_variables.sort.map {|e| [e, (eval e).inspect] }
  end

  # @render_options :fields=>{:default=>[:require_path, :full_path]}, :sort=>'require_path'
  # @options :reload=>:boolean
  # Prints loaded paths and their full paths
  def loaded_paths(options={})
    @loaded_paths = RubyRef.get_loaded_paths if options[:reload] || @loaded_paths.nil?
    @loaded_paths.inject([]) {|t,(k,v)| t << {:require_path=>k, :full_path=>v } }
  end

  # @render_options :headers=>{:default=>{0=>"name", 1=>"value"}}
  # Rbconfig constants and their values
  def rbconfig
    require 'rbconfig'
    RbConfig::CONFIG
  end

  # @render_options {}
  # Table of an object's instance variables
  def instance_var_table(obj)
    obj.instance_variables.map {|e| [e, obj.instance_variable_get(e).inspect] }
  end

  # @render_options :headers=>{:default=>{0=>'name', 1=>'version'}}
  # @options :loaded_path=>:boolean
  # List versions of currently loaded gems
  def version_list(options)
    options[:loaded_path] ? $:.map {|e| e =~ /\/([\w-]+)-(\d\.\d(\.\d)?)\/lib/ ?
      [$1,$2] : nil }.compact.uniq :
      Gem.loaded_specs.values.map {|e| [e.name, e.version.to_s] }
  end

  def self.get_loaded_paths
    hash = {}
    $".each { |f|
      $:.each { |d|
        test_file = File.join(d, f)
        if test(?e,test_file)
          hash[f] = test_file
          break
        end
      }
    }
    hash
  end
end
