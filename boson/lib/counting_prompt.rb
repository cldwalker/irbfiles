# Extracted from anonymous script with original class name CharGrabber
require 'thread'
class CountingPrompt
  CLEAR_SCREEN = "\e[2J\e[f"
  COLORS = {:red => 1, :yellow => 3, :magenta => 5}
  class <<self
 
  def open_stty
    begin
      system("stty raw -echo")
      yield
    ensure
      system("stty -raw echo")
    end
  end
 
  def run
    $stdout.sync = true
    $stdin.sync = true
 
    out = ""
    threads = []
    finished = false
 
    puts "<CTRL-C> to exit"
    puts "<CTRL-D> to execute block"
    puts "(hit <SPACE> to continue)"
 
    open_stty do
      STDIN.getc
    end
    
    # Twitter-specific
    threads << Thread.new do
      until finished do
        print CLEAR_SCREEN
        len = ("%-3d " % [out.length])
        print case out.length
              when 0..110 then len
              when 111..130 then colorize(len, :yellow)
              when 131..140 then colorize(len, :magenta)
              when 141..1000 then colorize(len, :red)
              end
        print out
        sleep(0.08)
      end
    end
 
    # these control characters are all so messy. todo, really learn what's
    # going on here and clean this up
    open_stty do
      while c = STDIN.getc
        case c.chr
        when "\003"
          finished = true
          threads.each {|t| t.join}
          print CLEAR_SCREEN
          putsr out
          putsr "Goodbye"
          exit
        when "\177" then out = out.chop
        else
          case c
          when 4
            finished = true
            threads.each {|t| t.join}
            print CLEAR_SCREEN
            block_given? ? yield(out) : putsr("No action given")
          when 27 then true
          when 32..128 then out << c # todo, bigger regexp
          else
            # ignore
          end
        end
      end
    end 
  end

  def putsr(msg)
    print msg + "\r\n"
  end

  def colorize(str, color)
    "\033[0;#{COLORS[color]+30}m#{str}\033[0m"
  end
  end
end