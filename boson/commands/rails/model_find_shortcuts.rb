module ModelFindShortcuts
  def self.included(mod)
    IRB_PROCS[:define_model_procs] = lambda { define_model_find_shortcuts }
    define_model_find_shortcuts(mod)
  end

  #from http://www.clarkware.com/cgi/blosxom/2007/09/03#ConsoleFindShortcut
  def self.define_model_find_shortcuts(mod)
    model_files = Dir.glob("app/models/**/*.rb")
    table_names = model_files.map { |f| File.basename(f).split('.')[0..-2].join }
    table_names.each do |table_name|
      mod.module_eval do
        define_method(table_name) do |*args|
          table_name.camelize.constantize.send(:find, *args)
        end
      end
    end
  end
end