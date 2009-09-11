module Tree
  options :as=>:optional, :children_method=>:optional, :type=>:optional
  # Prints an inheritance tree given a root class
  def inheritance_tree(klass, options={})
    render klass, {:as=>:parent_child_tree, :children_method=>:class_children, :type=>:directory}.merge(options)
  end

  # Prints an inheritance tree without Exception classes
  options :as=>:optional, :children_method=>:optional, :type=>:optional
  def errorless_inheritance_tree(klass, options={})
    child_lambda = lambda {|n| n.class_children.reject {|e| e < Exception || e.name =~ /Errno/} }
    render klass, {:as=>:parent_child_tree, :children_method=>child_lambda, :type=>:directory}.merge(options)
  end

  options :as=>:optional, :children_method=>:optional, :type=>:optional
  # Prints a tree of nested classes under a given
  def nested_tree(klass, options={})
    render klass, {:as=>:parent_child_tree, :children_method=>:nested_children, :value_method=>:nested_name, :type=>:directory}.merge(options)
  end
end