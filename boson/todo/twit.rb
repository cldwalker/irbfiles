#!/usr/bin/env ruby
require 'rubygems'
require 'thread'
 
begin
  require 'twitter'
rescue LoadError => e
  puts "The 'twitter' gem is required. Try 'sudo gem install twitter', then setup a ~/.twitter file"
  exit 1
end
 
class Object
  def putsr(msg)
    print msg + "\r\n"
  end
end
 
class String
  COLORS = {:red => 1, :yellow => 3, :magenta => 5}
 
  def colorize(color)
    return "\033[0;#{COLORS[color]+30}m#{self}\033[0m"
  end
end
 
class Tweeter
  def post(msg)
    begin
      config = YAML::load(open(ENV['HOME'] + '/.twitter'))
    rescue Exception => e
      putsr "Error loading $HOME/.twitter . Please make sure this is setup correctly"
    end
 
    twitter = Twitter::Base.new(config['email'], config['password'])
 
    putsr "Sending twitter update"
    finished, status = false, nil
    progress_thread = Thread.new { until finished; print "."; $stdout.flush; sleep 0.5; end; }
    post_thread = Thread.new(binding()) do |b|
      status = twitter.post(msg, :source => Twitter::SourceName)
      finished = true
    end
    post_thread.join
    progress_thread.join
    putsr "Got it! New tweet created at: #{status.created_at}\n"
  end
end
 
class CharGrabber
  CLEAR_SCREEN = "\e[2J\e[f"
 
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
    puts "<CTRL-D> to post"
    puts "(hit <SPACE> to continue)"
 
    open_stty do
      STDIN.getc
    end
    
    threads << Thread.new do
      until finished do
        print CLEAR_SCREEN
        len = ("%-3d " % [out.length])
        print case out.length
              when 0..110 then len
              when 111..130 then len.colorize(:yellow)
              when 131..140 then len.colorize(:magenta)
              when 141..1000 then len.colorize(:red)
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
          putsr "discarding, goodbye"
          exit
        when "\177" then out = out.chop
        else
          case c
          when 4
            finished = true
            threads.each {|t| t.join}
            print CLEAR_SCREEN
            putsr "posting: #{out}"
            Tweeter.new.post(out)
            exit
            
          when 27 then true
          when 32..128 then out << c # todo, bigger regexp
          else
            # ignore
          end
        end
      end
    end
 
 
  end
end
 
CharGrabber.new.run
