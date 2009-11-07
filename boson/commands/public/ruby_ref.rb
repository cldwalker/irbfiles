# Gives useful info about current environment
module RubyRef
  # @render_options :change_fields=>{:default=>{0=>"variable",1=>"value"}}
  # Prints global variables and their values
  def global_var
    global_variables.sort.map {|e| [e, (eval e).inspect] }
  end

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
  # @options :loaded_path=>:boolean
  # List versions of currently loaded gems
  def gem_versions(options={})
    if options[:loaded_path]
      $:.map {|e| e =~ /\/([\w-]+)-(\d\.\d(\.\d)?)\/lib/ ? [$1,$2] : nil }.compact.uniq
    else
      Gem.loaded_specs.values.map {|e| [e.name, e.version] }
    end
  end
end
