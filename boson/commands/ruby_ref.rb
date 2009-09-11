module RubyRef
  # Prints global variables and their values
  def global_var
    render global_variables.sort.map {|e| [e, (eval e).inspect] }, :headers=>{0=>"variable",1=>"value"}
  end
  
  # Prints loaded paths and their full paths
  def loaded_paths(reload=false)
    @loaded_paths = get_loaded_paths if reload || @loaded_paths.nil?
    render @loaded_paths.inject([]) {|t,(k,v)| t << {:require_path=>k, :full_path=>v } }.sort_by {|e| e[:require_path]},
      :fields=>[:require_path, :full_path]
  end

  # Hash of class dependencies excluding error-related ones
  def dependencies
    deps = {}
    ObjectSpace.each_object Class do |mod|
    next if mod.name =~ /Errno/
    next if mod < Exception
    deps[mod.to_s] = mod.superclass.to_s
    end
    deps
  end

  # Array of full paths
  def full_paths
    get_loaded_paths.values
  end

  # Rbconfig constants and their values
  def rbconfig
    require 'rbconfig'
    render RbConfig::CONFIG , :header=>{0=>"name", 1=>"value"}
  end

  # Table of an object's instance variables
  def instance_var_table(obj)
    render obj.instance_variables.map {|e| [e, obj.instance_variable_get(e).inspect] }
  end

  private
  def get_loaded_paths
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
