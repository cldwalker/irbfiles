# Allows instant underscore aliasing for commands/methods of main and namespaces. If multiple matches are found,
# the matches are printed. If only one method is found, it's executed.
module MethMissing
  def self.after_included
    Boson::BareRunner.define_autoloader
    [class <<Boson.main_object; self end, Boson::Namespace].each do |klass|
      define_method_missing klass
      klass.send :private, :method_missing
    end
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
        new_meth = meths[0]
        puts "Found method #{new_meth}" if Boson.verbose
        MethMissing.update_bin_runner(meth.to_s, new_meth) if Boson.in_shell
        send(new_meth, *args)
      else
        # meths == 1 : for methods loaded by autoloader
        new_meth = meths.size == 1 ? meths[0] : meth
        puts "Found method #{new_meth}" if Boson.verbose
        MethMissing.update_bin_runner(meth.to_s, new_meth.to_s) if Boson.in_shell && meth != new_meth
        original_method_missing.bind(self).call(new_meth.to_sym,*args)
      end
    end
  end

  def self.update_bin_runner(original_meth, new_meth)
    nsp = Boson::NAMESPACE
    if Boson::BinRunner.command.include?(nsp)
      namespace = Boson::BinRunner.command.split(nsp)[0]
      original_meth, new_meth = "#{namespace}#{nsp}#{original_meth}", "#{namespace}#{nsp}#{new_meth}"
    end
    Boson::BinRunner.command = new_meth
    (index = Boson::BinRunner.commands.index(original_meth)) &&
      Boson::BinRunner.commands[index] = new_meth
  end
end
