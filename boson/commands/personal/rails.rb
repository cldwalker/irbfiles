module RailsLib
  def self.append_features(mod)
    super if ENV['RAILS_ENV']
  end

  def self.after_included
    IRB_PROCS[:setup_personal] = method(:setup_personal) if Object.const_defined?(:IRB_PROCS)
  end

  def self.setup_personal(*args)
    Alias.create :file=>"~/.alias/rails.yml"
    require 'console_update' #gem install cldwalker-console_update
    ConsoleUpdate.enable_named_scope
  end
end