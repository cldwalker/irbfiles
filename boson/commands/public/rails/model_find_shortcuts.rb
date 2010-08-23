module ModelFindShortcuts
  def self.append_features(mod)
    super if ENV['RAILS_ENV'] || defined? Rails
  end

  #from http://www.clarkware.com/cgi/blosxom/2007/09/03#ConsoleFindShortcut
  def define_model_find_shortcuts(mod=ModelFindShortcuts)
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
