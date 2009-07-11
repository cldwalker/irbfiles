module IrbCompletion
  # append_character, quote_characters, word_break_characters, case_fold, filename_quote_char, basic_quote_char
  def self.included(mod)
  end

  def set_proc
    LocalGem.local_require 'bond'
    Bond.complete(:command=>"req") {|e,f|
      %w{would be nice if works}.grep(/#{e}/)
    }
    Bond.complete(:on=>/\s*["']([^'"]*)$/) {|input, match|
      (Readline::FILENAME_COMPLETION_PROC.call(match[1]) || []).map {|e|
        e =~ /^~/ ?  File.expand_path(e) : e
      }
    }
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