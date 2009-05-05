begin
  LocalGem.local_require 'hirb'
rescue
  require 'hirb'
end
extend Hirb::Console

module TreeMethods
  def itree(klass, options={})
    view klass, :parent_child_tree, {:children_method=>:class_children, :type=>:directory}.merge(options)
  end
  
  def ntree(klass, options={})
    view klass, :parent_child_tree, {:children_method=>:nested_children, :value_method=>:nested_name, :type=>:directory}.merge(options)
  end
end
extend TreeMethods