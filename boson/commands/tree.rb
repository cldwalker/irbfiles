module Tree
  options :as=>:optional, :children_method=>:optional, :type=>:optional
  def inheritance_tree(klass, options={})
    render klass, {:as=>:parent_child_tree, :children_method=>:class_children, :type=>:directory}.merge(options)
  end
  
  options :as=>:optional, :children_method=>:optional, :type=>:optional
  def nested_tree(klass, options={})
    render klass, {:as=>:parent_child_tree, :children_method=>:nested_children, :value_method=>:nested_name, :type=>:directory}.merge(options)
  end
end