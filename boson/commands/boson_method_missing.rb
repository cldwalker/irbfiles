# Allows instant aliasing of commands. If only one alias matches a command,
# the command is loaded and executed via the autoloader. Otherwise, the matching commands are printed.
module BosonMethodMissing
  def boson_method_missing
    Boson::Runner.define_autoloader
    class << Boson.main_object
      original_method_missing = Boson.main_object.method(:method_missing)
      define_method :method_missing do |meth,*args|
        Boson::Index.read
        possible_commands = Boson::Index.all_main_methods.sort
        meths = _underscore_search(meth.to_s, possible_commands)
        meths = [meth.to_s] if possible_commands.include?(meth.to_s)
        if meths.size > 1
          puts "Multiple methods match: #{meths.join(', ')}"
        elsif (meths.size == 1)
          puts "Found method #{meths[0]}"
          Boson::BinRunner.command = Boson::BinRunner.command.sub(meth.to_s, meths[0]) if Boson.const_defined?(:BinRunner)
          original_method_missing.call(meths[0],*args)
        else
          original_method_missing.call(meth,*args)
        end
      end

      # Allows aliasing of underscored words. For example 'some_dang_long_word' can be specified as 's_d_l_w'.
      def _underscore_search(input, list)
        if input.include?("_")
          index = 0
          input.split('_').inject(list) {|new_list,e|
            new_list = new_list.select {|f| f.split(/_+/)[index] =~ /^#{Regexp.escape(e)}/ };
            index +=1; new_list
          }
        else
          list.grep(/^#{Regexp.escape(input)}/)
        end
      end
    end
  end
end