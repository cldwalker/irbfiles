module StringLib
  # @desc Counts # of times the given string is in the string. This is unlike String.count which
  # only counts the given characters.
  def count_any(string)
    count = 0
    self.gsub(string) {|s| 
      count += 1
      string
    }
    count
  end

  # Pipes stringing to command
  def pipe(string, cmd)
    IO.popen(cmd, 'r+') do |pipe|
      pipe.write(string)
      pipe.close_write
      pipe.read
    end
  end
end
