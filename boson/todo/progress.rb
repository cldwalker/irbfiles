#from http://dotfiles.org/~brendano/.irbrc
  def progress(method, interval=100)
    count = 0
    ret = send(method) { |x|
      print "." if (count+=1) % interval == 0
      yield x
    }
    puts
    ret
  end

