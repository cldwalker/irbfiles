# Allows instant aliasing of commands. If only one alias matches a command,
# the command is loaded and executed via the autoloader. Otherwise, the matching commands are printed.
module BosonMethodMissing
  def boson_method_missing
    Boson::Runner.define_autoloader
    class << Boson.main_object
      original_method_missing = Boson.main_object.method(:method_missing)
      define_method :method_missing do |meth,*args|
        Boson::Index.read
        possible_commands = Boson::Index.commands.map {|e| [e.name, e.alias]}.flatten.compact.sort
        meths = _underscore_search(meth.to_s, possible_commands)
        if meths.size > 1
          puts "Multiple commands match: #{meths.join(', ')}"
        else
          puts "Found command #{meths[0]}" if meths[0]
          # attempt to prevent double error but swallows command
          # Boson::BinRunner.command = meths[0] if meths[0] && Boson.constant_defined?(:BinRunner)
          meth = (meths[0] || meth).to_sym
          respond_to?(meth) ? send(meth, *args) : original_method_missing.call(meth,*args)
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