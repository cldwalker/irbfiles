module StringLib
  # @desc Counts # of times the given string is in the string. This is unlike String.count which
  # only counts the given characters.
  def count_any(str)
    count = 0
    self.gsub(str) {|s| 
      count += 1
      str
    }
    count
  end

  # Pipes string to command
  def pipe(str, cmd)
    IO.popen(cmd, 'r+') do |pipe|
      pipe.write(str)
      pipe.close_write
      pipe.read
    end
  end
end