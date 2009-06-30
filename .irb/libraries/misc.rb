module Misc
  #Reloads a file just as you would require it.
  def reload(filename)
    filename += '.rb' unless filename[/\.rb$/]
    $".delete(filename)
    require(filename)
  end

  # A more versatile version of Module#const_get.
  # Retrieves constant for given string, even if it's nested under classes.
  def any_const_get(name)
    klass = ::Object
    name.split('::').each {|e|
      klass = klass.const_get(e)
    }
    klass
  rescue
    nil
  end

  def undetected_methods(priv=false)
    public_undetected = metaclass.instance_methods - (Kernel.instance_methods + Object.instance_methods(false) + MyCore::Object::InstanceMethods.instance_methods +
      Boson.commands.map {|e| [e[:name], e[:alias]] }.flatten.compact + IRB::ExtendCommandBundle.instance_eval("@ALIASES").map {|e| e[0].to_s})
    priv ? (public_undetected + metaclass.private_instance_methods - (Kernel.private_instance_methods + Object.private_instance_methods)) : public_undetected
  end

  def detect(*args, &block)
    Boson::Util.detect(*args, &block)
  end

  # from http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/
  def color_table
    [0, 1, 4, 5, 7].each do |attr|
      puts '----------------------------------------------------------------'
      puts "ESC[#{attr};Foreground;Background"
      30.upto(37) do |fg|
        40.upto(47) do |bg|
          print "\033[#{attr};#{fg};#{bg}m #{fg};#{bg}  "
        end
      puts "\033[0m"
      end
    end
  end
end