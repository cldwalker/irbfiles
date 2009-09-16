module PathFinder
  # option :gemdir, "Include paths to gem directories as defined by your gem binary"
  # option :dir, "Return directories of files"
  # options :verbose=>:boolean, :gemdir=>:boolean, :dir=>:boolean
  # Looks in standard ruby's library paths for a given file's basename.
  def path_finder(basename, options={})
    require 'find'
    files =[]
    searchdirs = $:
    if options[:gemdir]
            gemdirs = `gem environment gempath`.chomp.split(":")
            searchdirs += gemdirs
    end
    searchdirs.delete('.')
    i = 0

    Find.find(*searchdirs) do |f|
            puts "#{i}:#{f}" if options[:verbose]
            files.push(f) if f =~ /\/#{basename}\.(so|rb|bundle)$/
            i+=1
    end
    result = files.uniq
    result.map! { |f| File.dirname(f) } if options[:dir]
    puts result
  end
end