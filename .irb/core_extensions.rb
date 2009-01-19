# Enable items.map(&:name) a la Rails
class Symbol
  def to_proc
    lambda {|*args| args.shift.__send__(self, *args)}
  end
end 

# Convenience method on Regexp so you can do
# /an/.show_match("banana")
# stolen from the pickaxe
class Regexp
  def show_regexp(a, re)
     if a =~ re
        "#{$`}<<#{$&}>>#{$'}"
     else
        "no match"
     end
  end
  def show_match(a)
    show_regexp(a, self)
  end
end

# gaining temporary access to private methods
# http://blog.jayfields.com/2007/11/ruby-testing-private-methods.html
class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    self.class_eval { public *saved_private_instance_methods }
    yield
    self.class_eval { private *saved_private_instance_methods }
  end
end

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end

# A real array def, not a set diff
# a1 = [1,1,2]
# a2 = [1,2]
# a1 - a2 #=> []
# a1.diff(a2) #=> [1]
class Array
  def diff(other)
    list = self.dup
    other.each { |elem| list.delete_at( list.index(elem) ) }
    list
  end
end
