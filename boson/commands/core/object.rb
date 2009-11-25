module ObjectLib
  # Returns eigenclass/metaclass/singleton-class of given object
  def metaclass(obj)
    class << obj; self; end
  end

  # List methods which aren't in superclass
  def local_methods(obj)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end

  # Inspects the object or yields. Useful in method chains.
  def insp(obj)
    if block_given? then
      yield obj
    else
      p obj
    end
    obj
  end

  # Calls an object's original method
  def original_method(obj, meth, klass=Object)
    klass.instance_method(meth).bind(obj).call
  end
end
