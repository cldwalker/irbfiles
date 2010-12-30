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

  # From http://d.hatena.ne.jp/namutaka/20101225/1293292912
  # Print object's ancestors grouping modules by class
  def show_ancestors(obj)
    klass = obj.is_a?(Class) ? obj : obj.class
    inc_mods = klass.included_modules
    klass.ancestors.each do |c|
      puts inc_mods.include?(c) ? "-#{c}" : "#{c}"
    end
  end

  # From http://d.hatena.ne.jp/namutaka/20101225/1293292912
  # Grep methods and display where they came from
  def grep_methods(obj, pattern=nil)
    klass = obj.is_a?(Class) ? obj : obj.class
    ancs = klass.ancestors
    mtds = pattern ? obj.methods.grep(Regexp.new(pattern.to_s)) : obj.methods
    mtds.sort.each do |e|
      ent = ancs.find {|c| c.instance_methods(false).include?(e) } || "self"
      puts "#{e} in #{ent}"
    end
  end
end
