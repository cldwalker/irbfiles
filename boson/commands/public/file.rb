module FileLib
  #mac only: http://stream.btucker.org/post/65635235/file-creation-date-in-ruby-on-macs
  # Creation time for a file on a Mac
  def creation_time(file)
    require 'open3'
    require 'time'
    Time.parse( Open3.popen3("mdls", 
      "-name","kMDItemContentCreationDate", 
      "-raw", file)[1].read)
  end

  # Writes string to file
  def string_to_file(string,file)
    File.open(file,'w') {|f| f.write(string) }
  end

  #Returns array of lines up until the given string matches a line of the file.
  def read_until(file,string)
    f = File.readlines(file)
    f.slice(0, f.index(string) || f.size)
  end
end