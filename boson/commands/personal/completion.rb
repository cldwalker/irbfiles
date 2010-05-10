module Completion
  def self.included(mod)
    begin LocalGem.local_require 'bond'; rescue; require 'bond' end
  end

  def self.after_included
    Bond::M.reset
    Bond.start :debug=>true
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
