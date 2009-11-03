module Progress
  #from http://dotfiles.org/~brendano/.irbrc
  def prog(method, interval=100)
    count = 0
    ret = send(method) { |x|
      print "." if (count+=1) % interval == 0
      yield x
    }
    puts
    ret
  end

  # http://snippets.dzone.com/posts/show/3760
  def prog2
    # move cursor to beginning of line
    cr = "\r"
    # ANSI escape code to clear line from cursor to end of line
    # "\e" is an alternative to "\033"
    # cf. http://en.wikipedia.org/wiki/ANSI_escape_code
    clear = "\e[0K"
    # reset lines
    reset = cr + clear
    chars = [ "|", "/", "-", "\\" ]
    # 7 turns on reverse video mode, 31 red , ...
    n = 31
    str = "#{reset}\e[#{n};1m"

    (1..100).each do |i|
       case i
          when   0..10    then print "#{str}#{chars[0]}"
          when  10..20    then print "#{str}#{chars[1]}"
          when  20..30    then print "#{str}#{chars[2]}"
          when  30..40    then print "#{str}#{chars[3]}"
          when  40..50    then print "#{str}#{chars[0]}"
          when  50..60    then print "#{str}#{chars[1]}"
          when  60..70    then print "#{str}#{chars[2]}"
          when  70..80    then print "#{str}#{chars[3]}"
          when  80..90    then print "#{str}#{chars[0]}"
          when  90..100   then print "#{str}#{chars[1]}"
       end

       sleep(0.1)
       $stdout.flush
    end
  end
end
