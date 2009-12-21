# Gives useful info about current environment
module RubyRef
  # @render_options :change_fields=>{:default=>{0=>"variable",1=>"value"}}
  # Prints global variables and their values
  def global_var
    global_variables.sort.map {|e| [e, (eval e).inspect] }
  end

  # @config :default_option=>'query'
  # @render_options :change_fields=>{:default=>{0=>'require_path', 1=>'full_path'}}, :sort=>'require_path'
  # Prints loaded paths and their full paths
  def loaded_paths
    hash = {}
    $".each {|file|
      $:.each {|dir|
        if test(?e, File.join(dir, file))
          hash[file] = File.join(dir, file)
          break
        end
      }
    }
    hash
  end

  # @render_options :change_fields=>{:alias=>false, :default=>{0=>"name", 1=>"value"}}
  # Rbconfig constants and their values
  def rbconfig
    require 'rbconfig'
    RbConfig::CONFIG
  end

  # @render_options :change_fields=>{:default=>{0=>'instance', 1=>'value'}},
  #   :filters=>{:default=>{'value'=>:inspect}}
  # Table of an object's instance variables
  def instance_var(obj)
    obj.instance_variables.map {|e| [e, obj.instance_variable_get(e)] }
  end

  # @render_options :change_fields=>{:default=>{0=>'name', 1=>'version'}}
  # @options :loaded_path=>{:type=>:boolean, :desc=>'Use $LOADED_PATH to detect gems'}
  # List versions of currently loaded gems by using Gem's loaded_specs
  def gem_versions(options={})
    if options[:loaded_path]
      $:.map {|e| e =~ /\/([\w-]+)-(\d\.\d(\.\d)?)\/lib/ ? [$1,$2] : nil }.compact.uniq
    else
      Gem.loaded_specs.values.map {|e| [e.name, e.version] }
    end
  end

  # @render_options :change_fields=>{:default=>{0=>'class', 1=>'object_count'}}, :reverse_sort=>true,
  #   :sort=>'object_count'
  # Displays the number of objects per class
  def object_count
    object_hash = {}
    ObjectSpace.each_object {|e| (object_hash[e.class] ||= []) << e }
    object_hash.each {|k,v| object_hash[k] = v.size }
  end

  # @render_options :change_fields=>{:default=>{0=>'method', 1=>'value'}}, :sort=>'method'
  # Lists an object's methods and values for methods that don't take arguments
  def method_values(obj)
    argumentless_methods = obj.class.instance_methods(false).select {|e| obj.method(e).arity.zero? }
    argumentless_methods.map {|e| [e, obj.send(e)] }
  end
end