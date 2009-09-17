module Tree
  OPTIONS = {:as=>:string, :children_method=>:string, :type=>{:type=>:string, :values=>[:directory, :basic, :number]}}
  # @options OPTIONS
  # Prints an inheritance tree given a root class
  def inheritance_tree(klass, options={})
    render klass, {:as=>:parent_child_tree, :children_method=>:class_children, :type=>:directory}.merge(options)
  end

  # @options OPTIONS
  # Prints an inheritance tree without Exception classes
  def errorless_inheritance_tree(klass, options={})
    child_lambda = lambda {|n| n.class_children.reject {|e| e < Exception || e.name =~ /Errno/} }
    render klass, {:as=>:parent_child_tree, :children_method=>child_lambda, :type=>:directory}.merge(options)
  end

  # @options OPTIONS
  # Prints a tree of nested classes under a given
  def nested_tree(klass, options={})
    render klass, {:as=>:parent_child_tree, :children_method=>:nested_children, :value_method=>:nested_name, :type=>:directory}.merge(options)
  end
end