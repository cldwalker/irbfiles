def pz(*args)
  sub = parse_caller(caller[0])[0][2] || "'nil'"
  print sub + ": "
  p *args
end

def parse_caller(*caller_elements)
  caller_elements.map {|e|
    file,line, sub = e.split(":")
    sub =~ /in `(\w+)'/
    sub = $1
    [file,line,sub]
  }
end

def debug_require(&block)
	debug_method('require',&block)
end

def debug_load(&block)
	debug_method('load',&block)
end

def debug_method(method, &block)
	@block = block
	original_method = "_#{method}"
	eval %[
	class Object
		alias_method :#{original_method}, :#{method}
		def #{method}(*args)
			if @block
				@block.call(args)
			else
				pz [args, caller[0,3]]
			end
			#{original_method}(*args)
		end
	end
	]
end
