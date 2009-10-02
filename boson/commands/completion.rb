module ::Bond
  module Actions
    def alias_constants(input)
      fetch_constants = proc {|klass, klass_alias| klass.constants.grep(/^#{klass_alias}/i).map {|f| klass.const_get(f)} }
      fetch_string_constants = proc {|klass, klass_alias|
        klass.constants.grep(/^#{klass_alias}/i).map {|f|
          (val = klass.const_get(f)) && val.is_a?(Module) ? val.to_s : "#{klass}::#{f}"
        }
      }

      index = 1
      aliases = input.split(":")
      aliases.inject([Object]) do |completions,a|
        completions = completions.select {|e| e.is_a?(Module) }.map {|klass|
          aliases.size != index ? fetch_constants.call(klass, a) : fetch_string_constants.call(klass, a)
        }.flatten
        index += 1; completions
      end
    end

    def my_constants(input)
      receiver = input.matched[1]
      candidates = current_eval("#{receiver}.constants")
      candidates.grep(/^#{Regexp.escape(input.matched[4])}/).map {|e| receiver + "::" + e}
    end
  end
end

module Completion
  def load_bond
    begin LocalGem.local_require 'bond'; rescue; require 'bond' end
    Bond.reset
    Bond.debrief :debug=>true, :default_search=>:underscore
    require 'bond/completion'
    Bond.complete(:on=>/(((::)?[A-Z][^:.\(]*)+)::?([^:.]*)$/, :action=>:my_constants, :search=>false, :place=>3)
    # place it before symbols
    Bond.complete(:on=>/^((([a-z][^:.\(]*)+):)+/, :search=>false, :action=>:alias_constants, :place=>6)
    Bond.complete(:method=>"reload") {|e| $" }
    Bond.complete(:method=>/ll|bl/) {|e|  Boson::Runner.all_libraries }
    Bond.complete(:method=>'r', :action=>:method_require, :search=>false)
    Bond.complete(:method=>'bc') {|e| Boson.commands.map {|e| e.name} }
    Bond.complete(:on=>/ENV\[["'](\S*)$/, :search=>false) {|e| ENV.keys.grep(/^#{Regexp.escape(e.matched[1])}/i) }
  end

  # Toggles object completion between all methods and just the object's class methods
  def toggle_object_complete
    if @object_complete
      Bond.recomplete(:object=>'Object', :place=>:last)
      Bond.recomplete(:object=>'Object', :on=>/([^.\s]+)\.([^.\s]*)$/, :place=>:last)
    else
      non_inherited_methods = proc {|e|
        e.object.is_a?(Module) ? e.object.methods(false) : e.object.class.instance_methods(false)
      }
      Bond.recomplete(:object=>'Object', :place=>:last, &non_inherited_methods)
      Bond.recomplete(:object=>'Object', :on=>/([^.\s]+)\.([^.\s]*)$/, :place=>:last, &non_inherited_methods)
    end
    @object_complete = !@object_complete
  end
end
