module TreeCommands
  def self.init
    require 'libraries/core'
    require 'libraries/hirb'
  end

  def inheritance_tree(klass, options={})
    view klass, :parent_child_tree, {:children_method=>:class_children, :type=>:directory}.merge(options)
  end
  
  def nested_tree(klass, options={})
    view klass, :parent_child_tree, {:children_method=>:nested_children, :value_method=>:nested_name, :type=>:directory}.merge(options)
  end
end