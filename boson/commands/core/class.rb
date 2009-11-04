module ClassLib
  # Returns ancestors that aren't included modules and the class itself.
  def real_ancestors(klass)
    ancestors - included_modules - [klass]
  end

  #Returns all objects of class.
  def objects(klass)
    object = []
    ObjectSpace.each_object(klass) {|e| object.push(e) }
    object
  end

  # Return a class' immediate children.
  def class_children(klass)
  (@class_objects ||= ::Class.objects).select {|e| e.superclass == klass }
  end

  # from http://blog.jayfields.com/2007/11/ruby-testing-private-methods.html
  # Gain temporary access to private methods by wrapping code around this method's block.
  def publicize_methods(klass)
    saved_private_instance_methods = klass.private_instance_methods
    klass.class_eval { public *saved_private_instance_methods }
    yield
    klass.class_eval { private *saved_private_instance_methods }
  end
end