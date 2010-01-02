# This file contains the beginnings of reloading libraries in the console. Only
# implemented for FileLibrary kind of.
class ::Boson::Manager
  def self.reload(library, options={})
    if (lib = Boson.library(library))
      if lib.loaded
        command_size = Boson.commands.size
        @options = options
        if (result = rescue_load_action(lib.name, :reload) { lib.reload })
          after_reload(lib)
          puts "Reloaded library #{library}: Added #{Boson.commands.size - command_size} commands" if options[:verbose]
        end
        result
      else
        puts "Library hasn't been loaded yet. Loading library #{library}..." if options[:verbose]
        load(library, options)
      end
    else
      puts "Library #{library} doesn't exist." if options[:verbose]
      false
    end
  end

  def self.after_reload(lib)
    Boson.commands.delete_if {|e| e.lib == lib.name } if lib.new_module
    create_commands(lib, lib.new_commands)
  end
end

module ::Boson::Loader
  # Reloads a library from its source and adds new commands. 
  def reload
    original_commands = @commands
    reload_source_and_set_module
    detect_additions { load_module_commands } if @new_module
    @new_commands = @commands - original_commands
    true
  end

  # Same as load_source_and_set_module except it reloads.
  def reload_source_and_set_module
    raise LoaderError, "Reload not implemented"
  end
end

class ::Boson::FileLibrary
  def reload_source_and_set_module
    detected = detect_additions(:modules=>true) { load_source(true) }
    if (@new_module = !detected[:modules].empty?)
      @commands = []
      @module = determine_lib_module(detected[:modules])
    end
  end
end

module ReloadLibrary
  # Reloads a library or an array of libraries
  def reload_library(library, options={})
    Boson::Manager.reload(library, options)
  end
end

__END__

# from file_library_test.rb
test "with same module reloads" do
  load(:blah, :file_string=>"module Blah; def blah; end; end")
  File.stubs(:exists?).returns(true)
  File.stubs(:read).returns("module Blah; def bling; end; end")
  Manager.reload('blah').should == true
  command_exists?('bling')
  library('blah').commands.size.should == 2
end

test "with different module reloads" do
  load(:blah, :file_string=>"module Blah; def blah; end; end")
  File.stubs(:exists?).returns(true)
  File.stubs(:read).returns("module Bling; def bling; end; end")
  Manager.reload('blah').should == true
  library_has_module('blah', "Boson::Commands::Bling")
  command_exists?('bling')
  command_exists?('blah', false)
  library('blah').commands.size.should == 1
end
