# Allows instant underscore aliasing for commands/methods of main and namespaces. If multiple matches are found,
# the matches are printed. If only one method is found, it's executed.
module MethMissing
  def self.after_included
    Boson::Runner.define_autoloader
    define_method_missing class <<Boson.main_object; self end
    define_method_missing Boson::Namespace
  end

  def self.define_method_missing(klass)
    original_method_missing = klass.instance_method(:method_missing)
    klass.send(:define_method, :method_missing) do |meth,*args|
      possible_meths = self.is_a?(Boson::Namespace) ? self.boson_commands :
        Boson::Index.read && (Boson.commands.map {|e| e.name} + Boson::Index.all_main_methods).uniq
      meths = Boson::Util.underscore_search(meth.to_s, possible_meths)
      if meths.size > 1
        puts "Multiple methods match: #{meths.join(', ')}"
      elsif (meths.size == 1) && respond_to?(meths[0])
        puts "Found method #{meths[0]}" if Boson::Runner.verbose?
        Boson::BinRunner.command = Boson::BinRunner.command.sub(meth.to_s, meths[0]) if Boson::Runner.in_shell?
        send(meths[0], *args)
      else
        meth = meths[0] if meths.size == 1 # for methods loaded by autoloader
        original_method_missing.bind(self).call(meth,*args)
      end
    end
  end
end