# Misc shell commands
module ShellCommands
  # Swaps names of two files
  def file_swap(file1, file2)
    tempfile = '_temp_file_you_should_not_have'
    File.rename(file1,tempfile)
    File.rename(file2,file1)
    File.rename(tempfile,file2)
  end

  # Set a countdown timer to remind me to take a break using Mac say command.
  def reminder(minutes, message="Time is up biaaatch!")
    minutes = minutes.to_f * 60
    sleep(minutes)
    system('say', message)
  end

  # Lists largest directories under given directories by traversing full depth of directories.
  def directory_sizer(dir)
    dirs = `find #{dir} -type d -exec du -sh {} \\;`.split("\n")
    dirs.shift #first result is the directory we give
    puts dirs.sort {|a,b| numerical_value(b) <=>numerical_value(a) }.slice(0,10).join("\n")
  end

  # Ejects latest volume (ie usb device) in Mac OsX. Works with OsX version >= 10.4.
  def eject
    latest_dirs = `ls -t /Volumes`.split("\n")
    latest_dirs -= ['Macintosh HD']
    if ejectable = latest_dirs[0]
      puts "Ejecting: #{ejectable}"
      puts `hdiutil detach "/Volumes/#{ejectable}"`
    else
      puts "Nothing to eject"
    end
  end

  # @options :confirm=>:boolean
  # Renames files based on a matching regex and string to replace the matches
  def regname(regex, replace,files, options={})
    file_map = files.map {|e|
      val = [e, e.gsub(regex, replace)]
      puts "#{val[0]} -> #{val[1]}"
      val
    }
    if options[:confirm]
      puts "Ok?"
      return if $stdin.gets !~ /^y/
    end
    file_map.each do |old, new_name|
      File.rename(old, new_name)
    end
  end

  # from http://gist.github.com/217660
  # Checks to see if domain is registered
  def registered(domain)
    system("dig soa #{domain} | grep -q ^#{domain}") ? "Yes" : "No"
  end

  private
  # converts du -sh style number ie 23M or 42.0G to a ruby float
  def numerical_value(dir_line)
    dir_line =~ /^\s*(\S+)\s/
    du_number = $1
    size_letter = du_number[-1..-1]
    number = du_number.chop.to_f
    multiplier = case size_letter
      when "G" then 1000000000
      when "M" then 1000000
      when "K" then 1000
      else 1
    end
    number * multiplier
  end
end