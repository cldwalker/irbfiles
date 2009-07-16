module IrbCompletion
  # append_character, quote_characters, word_break_characters, case_fold, filename_quote_char, basic_quote_char
  def self.included(mod)
  end

  def set_proc
    LocalGem.local_require 'bond'
    # Bond.debrief :readline_plugin=>Bond::Rawline
    Bond.reset
    Bond.complete(:method=>"reload") {|e,f|
      $".map {|g| g.gsub('.rb','') }
    }
    Bond.complete(:method=>/ll|rl/) {|e,f|
      Dir["#{Boson.base_dir}/libraries/**/*.rb"].map {|l| l[/#{Boson.base_dir}\/libraries\/(.*)\.rb/,1]}
    }
    Bond.complete(:object=>"Array", :search=>:underscore)
    Bond.complete(:on=>/^(((([a-z][^:.\(]*)+):)+)([^:.]*)$/, :search=>false) {|e|
      const_complete(e)
    }

    # Bond.complete(:on=>/^(([a-z][^:.\(]*)+):([^:.]*)$/, :search=>false) {|e|
    # # Bond.complete(:on=>/^(((([a-z][^:.\(]*)+):)+)([^:.]*)$/, :search=>false) {|e|
    #   # const_get_proc = proc {|c| c.constants.grep(/^#{e.matched[1]}/i).map {|f| c.const_get(f) }.select{|f| f.is_a?(Module) } }
    #   # namespaces = e.split(":")
    #   # top_namespace = namespaces.shift
    #   # constants = const_get_proc.call(Object)
    #   parts = e.matched[0].split(":")
    #   last_part = parts.pop
    #   constants = create_constants([Object, parts])
    #   constants = grep_constants(Object, parts[0])
    #   constants.map {|f| f.constants.grep(/^#{last_part}/i).map {|g| "#{f}::#{g}"} }.flatten
    # }
    # Bond.complete(:object=>"Array", :search=>:underscore)
    # Bond.complete(:on=>/\S+\s*["']([^'"]*)$/, :search=>false) {|e|
    #   (Readline::FILENAME_COMPLETION_PROC.call(e.matched[1]) || []).map {|f|
    #     f =~ /^~/ ?  File.expand_path(f) : f
    #   }
    # }
  end

  def const_complete(query="a:c")
    fetch_constants = proc {|klass, query| klass.constants.grep(/^#{query}/i).map {|f| klass.const_get(f)} }
    fetch_string_constants = proc {|klass, query|
      klass.constants.grep(/^#{query}/i).map {|f|
        (val = klass.const_get(f)) && val.is_a?(Module) ? val.to_s : "#{klass}::#{f}"
      }
    }
    queries = query.split(":")
    completions = fetch_constants.call(Object, queries.shift)
    while (queries.size > 0) do
      completions = completions.select {|e| e.is_a?(Module) }.map {|e|
        queries.size != 1 ? fetch_constants.call(e, queries[0]) : fetch_string_constants.call(e, queries[0])
      }.flatten
      queries.shift
    end
    completions
  end

  def get_constants(klass, index, query_array)
    possible_completions = klass.constants.grep(/^#{query_array[index]}/i).map {|f| klass.const_get(f)}
    if index == query_array.size - 1
      p "added: #{possible_completions.inspect}"
      $completions += possible_completions
    else
      possible_completions.select {|e| e.is_a?(Module) }.each {|e|
        get_constants(e, index + 1, query_array)
      }
    end
  end

  def create_constants(arr)
    arr.map {|a,b| grep_constants(a,b)}
  end

  def grep_constants(klass, query)
    klass.constants.grep(/^#{query}/i).map {|f| klass.const_get(f) }.select{|f| f.is_a?(Module) }
  end

  def reset_readline
    Readline.basic_word_break_characters= " \t\n\"\\'`><=;|&{("
    Readline.completion_proc = IRB::InputCompletor::CompletionProc
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