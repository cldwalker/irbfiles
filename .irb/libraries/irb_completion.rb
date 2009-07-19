module Bond
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

    def shell_commands(input)
      ENV['PATH'].split(File::PATH_SEPARATOR).uniq.map {|e| Dir.entries(e) }.flatten.uniq
    end
  end
end

module Boson::Libraries::IrbCompletion
  def load_bond
    begin LocalGem.local_require 'bond'; rescue; require 'bond' end
    Bond.reset
    Bond.debrief :debug=>true
    Bond.complete(:method=>"reload") {|e|
      $".map {|f| f.gsub('.rb','') }
    }
    Bond.complete(:method=>/ll|rl/) {|e|
      Dir["#{Boson.base_dir}/libraries/**/*.rb"].map {|l| l[/#{Boson.base_dir}\/libraries\/(.*)\.rb/,1]}
    }
    Bond.complete(:method=>/system|`/, :action=>:shell_commands)
    Bond.complete(:object=>"Object", :search=>:underscore)
    Bond.complete(:on=>/^((([a-z][^:.\(]*)+):)+/, :search=>false, :action=>:alias_constants)

    # Bond.complete(:on=>/\S+\s*["']([^'"]*)$/, :search=>false) {|e|
    #   (Readline::FILENAME_COMPLETION_PROC.call(e.matched[1]) || []).map {|f|
    #     f =~ /^~/ ?  File.expand_path(f) : f
    #   }
    # }
  end

  def irb_enhanced
    if !$".grep(/irb-enhanced/).empty?
      reload 'irb-completion-enhanced'
    else
      $: << File.expand_path("~/.irb/lib/irb-enhanced")
      require 'irb-completion-enhanced'
    end
    IRB::InputCompletor.setup
  end
end