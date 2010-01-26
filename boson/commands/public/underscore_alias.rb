# This module instantly aliases underscored methods by redefining an object's method_missing().
# For example, 'object.y_a_l_m' would be an alias for 'object.yet_another_long_method'
# An alias will only execute if a match is unique. If not unique, possible matches are displayed.
# Recommended for console use only.

# Usage:
# Extends an object with underscore aliasing power
# >> object.extend UnderscoreAlias
#
# Gives objects of this class underscore aliasing power
# >> SomeClass.send :include, UnderscoreAlias
module ::UnderscoreAlias
  def self.included(mod)
    mod.module_eval do
      class<<self
        alias_method :old_allocate, :allocate
        def allocate(*args)
          obj = old_allocate(*args)
          obj.extend DefineMethodMissing
          obj
        end
      end

      alias_method :old_initialize, :initialize
      def initialize(*args, &block)
        old_initialize(*args, &block)
        self.extend DefineMethodMissing
      end
    end
  end

  def self.extended(obj)
    obj.extend(DefineMethodMissing)
  end
    

  module DefineMethodMissing
    def self.underscore_search(input, list)
      input = input.to_s
      if input.include?("_")
        underscore_regex = input.split('_').map {|e| Regexp.escape(e) }.join("([^_]+)?_")
        list.select {|e| e.to_s =~ /^#{underscore_regex}/ }
      else
        escaped_input = Regexp.escape(input)
        list.select {|e| e.to_s =~ /^#{escaped_input}/ }
      end
    end

    def method_missing(meth, *args, &block)
      possible_methods = self.methods.map {|e| e.to_s }.sort
      meths = DefineMethodMissing.underscore_search(meth.to_s, possible_methods)

      if meths.size > 1
        puts "Multiple methods match: #{meths.join(', ')}"
      elsif (meths.size == 1)
        send(meths[0], *args, &block)
      else
        super
      end
    end
  end
end
  