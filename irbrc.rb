# This irbrc provides a simple way to load preferred irb settings via
# a method irb_lib_* or a file under your irb base directory.

require 'rubygems'
#Set this to your preferred directory
irb_base_dir = "#{ENV['HOME']}/.irb"
IRB_BASE_DIR = File.exists?(irb_base_dir) ? irb_base_dir : '.irb'
$:.unshift IRB_BASE_DIR
require 'snippets'

#####   Defines IRB library loader ####
def load_irb_lib(*libraries)
  if libraries == [:all]
    libraries = (self.public_methods + self.private_methods).grep(/^#{IRB_METHOD_PREFIX}/).map {|e| e.gsub(IRB_METHOD_PREFIX, '') }

    #td: autoload files
    #Dir["#{ENV['HOME']}/.irb/*.rb"].map do |path|
    #basename = "#{path.scan(%r{([^/]*).rb$})}"
    #end
  end
  libraries.each do |e|
    _load_irb_lib(e) 
  end
end

def _load_irb_lib(library)
  begin
    if File.exists?(File.join(IRB_BASE_DIR, "#{library}.rb"))
      load File.join(IRB_BASE_DIR, "#{library}.rb")
      puts "Loaded library file '#{library}'" if $DEBUG
    elsif respond_to?("#{IRB_METHOD_PREFIX}#{library}", true)
      send("#{IRB_METHOD_PREFIX}#{library}")
      puts "Loaded library method '#{library}'" if $DEBUG
    else
      puts "Library '#{library}' not found"
    end
  rescue LoadError
    puts "Failed to load '#{library}'"
  rescue Exception
    puts "Failed to load '#{library}'"
    puts "Reason: #{$!}"
  end
end

load_irb_lib(:irb_options, :wirble, :railsrc, :aliases, :history, :local_gem, :core_extensions, :method_lister, :hirb)
