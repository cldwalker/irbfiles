def page_stdout(&block)
  print_methods = %w{puts printf sprintf p print}
  print_methods.each {|e| override_print_method(e)}
  yield
  print_methods.each {|e| restore_print_method(e)}
end

def override_print_method(method)
  eval %[
    module ::Kernel
      alias :_#{method}_ :#{method}
      def #{method}(*args)
       :execute_override_here || _#{method}_(*args)
      end
    end
  ]
end

def restore_print_method(method)
  eval %[
    module ::Kernel
      alias :#{method} :_#{method}_
    end
  ]
end
