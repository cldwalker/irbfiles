module Completion
  def self.included(mod)
    begin LocalGem.local_require 'bond'; rescue; require 'bond' end
  end

  def self.after_included
    Bond.reset
    Bond.complete(:object_method=>true)
    meth_actions = {
      "Object#instance_of?"=>lambda { Boson.main_object.objects(Class) },
      "Object#instance_variable_get"=>lambda {|e| e.object.instance_variables },
      "Object#instance_variable_set"=>lambda {|e| e.object.instance_variables },
      "Object#remove_instance_variable"=>lambda {|e| e.object.instance_variables },
      "Object#method"=>lambda {|e|
        e.object.is_a?(Module) ? e.object.methods - e.object.class.methods : e.object.class.instance_methods(false)
      },
      "Object#send"=>lambda {|e| e.object.methods + e.object.private_methods - Kernel.methods },
      "Object#is_a?"=>lambda { Boson.main_object.objects(Module) },
      "Object#kind_a?"=>lambda { Boson.main_object.objects(Module) },
      "Module#const_get"=>lambda {|e| e.object.constants },
      "Module#const_set"=>lambda {|e| e.object.constants },
      "Module#remove_const"=>lambda {|e| e.object.constants },
      "Module#class_variable_get"=> lambda {|e| e.object.class_variables},
      "Module#class_variable_set"=> lambda {|e| e.object.class_variables},
      "Module#instance_method"=> lambda {|e| e.object.instance_methods(false) },
    }
    meth_actions.each {|k,v|
      Bond::Missions::ObjectMethodMission.add_method_action(k,&v)
    }
    Bond.load do
      complete(:method=>"reload") {|e| $" }
      complete(:method=>/ll|bl|rl/) {|e|
        (Boson::Runner.all_libraries + Boson::Runner.all_libraries.map {|e| File.basename e }).uniq
      }
      complete(:method=>'r', :action=>:method_require, :search=>false)
      complete(:method=>'bc') {|e| Boson.commands.map {|e| e.name} }
      complete(:method=>/raise|fail/) { Boson.main_object.objects(Class).select {|e| e < StandardError } }
    end
  end

  # Toggles object completion between all methods and just the object's class methods
  def toggle_object_complete
    if @object_complete
      Bond.recomplete(:object=>'Object', :place=>:last)
      Bond.recomplete(:object=>'Object', :on=>/([^.\s]+)\.([^.\s]*)$/, :place=>:last)
    else
      non_inherited_methods = proc {|e|
        e.object.is_a?(Module) ? e.object.methods(false) : e.object.class.instance_methods(false)
      }
      Bond.recomplete(:object=>'Object', :place=>:last, &non_inherited_methods)
      Bond.recomplete(:object=>'Object', :on=>/([^.\s]+)\.([^.\s]*)$/, :place=>:last, &non_inherited_methods)
    end
    @object_complete = !@object_complete
  end
end
