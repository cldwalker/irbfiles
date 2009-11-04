module ObjectLib
  # Returns eigenclass/metaclass/singleton-class of given object
  def metaclass(obj)
    class << obj; self; end
  end

  # list methods which aren't in superclass
  def local_methods(obj)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end
