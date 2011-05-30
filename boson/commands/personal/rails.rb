module RailsLib
  def self.append_features(mod)
    super if ENV['RAILS_ENV'] || defined? Rails
  end

  def self.after_included
    IRB_PROCS[:setup_personal] = method(:setup_personal) if Object.const_defined?(:IRB_PROCS)
  end

  def self.setup_personal(*args)
    require 'console_update'
    ConsoleUpdate.enable_named_scope unless Rails.version >= '3.0'
  rescue LoadError
  ensure
    minimal_active_record_inspect if defined? ActiveRecord::Base
    Alias.create :file=>'config/alias.yml' if File.exists?('config/alias.yml') && Alias.manager.all_aliases.empty?
    Alias.create :file=>"~/.alias/rails.yml"
  end

  def self.minimal_active_record_inspect
    ActiveRecord::Base.class_eval %[def self.inspect; to_s; end ]
  end
end
