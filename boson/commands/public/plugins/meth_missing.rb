# Allows instant aliasing of commands. If only one alias matches a command,
# the command is loaded and executed via the autoloader. Otherwise, the matching commands are printed.
module MethMissing
  class <<self
    def after_included
      Boson::Runner.define_autoloader
      main_object_missing
      namespace_missing
    end

    def namespace_missing
      original_method_missing = Boson::Namespace.instance_method(:method_missing)
      Boson::Namespace.send(:define_method, :method_missing) do |meth,*args|
        Boson::Index.read
        meths = Boson::Util.underscore_search(meth.to_s, self.boson_commands)
        if meths.size > 1
          puts "Multiple methods match: #{meths.join(', ')}"
        elsif (meths.size == 1) && respond_to?(meths[0])
          puts "Found method #{meths[0]}" if Boson::Runner.verbose?
          Boson::BinRunner.command = Boson::BinRunner.command.sub(meth.to_s, meths[0]) if Boson::Runner.in_shell?
          send(meths[0], *args)
        else
          original_method_missing.bind(self).call(meth,*args)
        end
      end
    end

    def main_object_missing
      class << Boson.main_object
        original_method_missing = Boson.main_object.method(:method_missing)
        define_method :method_missing do |meth,*args|
          Boson::Index.read
          possible_commands = (Boson.commands.map {|e| e.name} + Boson::Index.all_main_methods).uniq.sort
          meths = possible_commands.include?(meth.to_s) ? [meth.to_s] : Boson::Util.underscore_search(meth.to_s, possible_commands)
          if meths.size > 1
            puts "Multiple methods match: #{meths.join(', ')}"
          elsif (meths.size == 1)
            puts "Found method #{meths[0]}" if Boson::Runner.verbose?
            Boson::BinRunner.command = Boson::BinRunner.command.sub(meth.to_s, meths[0]) if Boson::Runner.in_shell?
            Boson.can_invoke?(meths[0]) ? Boson.invoke(meths[0], *args) : original_method_missing.call(meths[0],*args)
          else
            original_method_missing.call(meth,*args)
          end
        end
      end
    end

  end
end