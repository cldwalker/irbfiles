#from http://dotfiles.org/~bogojoker/.irbrc
# Where quasi global methods belong (Thanks to aperios for teaching me!)
module Kernel
  
  # Copy the last IRB result into the clipboard
  # Thanks to aperios (apeiros@gmx.ne) in #ruby-lang  
  def pbcopy
    IO.popen('pbcopy', 'w') { |io| io.write(IRB.CurrentContext.last_value.to_s) }
  end
end

#from http://www.ruby-forum.com/topic/84414#15439
# fresh irb. It uses an at_exit handler to yield it a block is given.
# maybe just exec($0) ?
def reset_irb
  at_exit {exec($0)} # first registered is last to run
  at_exit {yield if block_given?}

  # From finalizer code in irb/ext/save-history.rb.. very ugly way to
do it :S.. who wants to rewrite irb?
  if num = IRB.conf[:SAVE_HISTORY] and (num = num.to_i) > 0
    if hf = IRB.conf[:HISTORY_FILE]
      file = File.expand_path(hf)
    end
    file = IRB.rc_file("_history") unless file
    open(file, 'w') do |file|
      hist = IRB::HistorySavingAbility::HISTORY.to_a
      file.puts(hist[-num..-1] || hist)
    end
  end

  # Make irb give us a clean exit (up until our at_exit handler above)
  throw :IRB_EXIT, 0
end

