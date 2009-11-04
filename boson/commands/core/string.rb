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
end