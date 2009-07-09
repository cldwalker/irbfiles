module IrbCompletion
  # append_character, quote_characters, word_break_characters, case_fold, filename_quote_char, basic_quote_char
  def set_proc(&block)
    Readline.basic_word_break_characters= " \t\n`><=;|&{("
    Readline.completion_proc = proc {|input|
      if input =~ /^(['"])/
        quote = $1
        (Readline::FILENAME_COMPLETION_PROC.call(input.tr(quote, '')) || []).map {|e| 
          e =~ /^~/ ?  quote + File.expand_path(e) : quote + e
        }
      else
        IRB::InputCompletor::CompletionProc.call(input)
      end
    }
  end

  def reset_readline
    Readline.basic_word_break_characters= " \t\n\"\\'`><=;|&{("
    Readline.completion_proc = IRB::InputCompletor::CompletionProc
  end

  def irb_enhanced
    $: << File.expand_path("~/.irb/lib/irb-enhanced")
    require 'irb-completion-enhanced'
    IRB::InputCompletor.setup
  end
end