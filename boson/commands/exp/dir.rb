# All methods here take an optional directory argument, defaulting to the current directory.
module DirLib
  # Returns current directory with a '/' appended.
  def mpwd
    Dir.pwd + "/"
  end

  # Returns entries from simple_entries() that are directories.
  def dir_children(dirname=mpwd)
    simple_entries(dirname).find_all {|e|
      File.directory?(File.join(dirname, e))
    }
  end

  # Returns entries from simple_entries() that are files.
  def file_children(dirname=mpwd)
    simple_entries(dirname).find_all {|e|
      File.file?(File.join(dirname,e))
    }
  end

  # You should override this method to take advantage of methods based on it.
  # @desc Returns everything in a directory that entries() would except
  # for '.', '..' and vim's backup files ie files ending with ~ or .sw*.
  def simple_entries(dirname=mpwd)
    dir_files = Dir.entries(dirname)
    files = dir_files - ['.','..'] - dir_files.grep(/~$/) - dir_files.grep(/\.sw[o-z]$/)
  end

  # Returns entries from simple_entries() that are not symlinks.
  def nonlink_entries(dirname=mpwd)
    simple_entries(dirname).select {|e|
      ! File.symlink?(File.join(dirname,e))
    }
  end

  #Returns the full paths of simple_entries().
  def full_entries(dirname=mpwd)
    simple_entries(dirname).map {|e| File.join(dirname,e) }
  end

  # @desc Returns all simple_entries under a directory for the specified depth. If no depth specified
  # it'll return all entries under the directory.
  def levels_of_children(dirname=mpwd,max_level=1000)
    @max_level = max_level
    @level_children = []
    get_level_children(dirname,0)
    @level_children
  end

  private
  #used recursively by levels_of_children
  def get_level_children(dirname,level) #:nodoc:
    dir_children = full_entries(dirname)
    @level_children += dir_children
    if level < @max_level
      dir_children.each {|e|
        if File.directory?(e)
          get_level_children(e,level + 1)
        end
      }
    end
  end
end
