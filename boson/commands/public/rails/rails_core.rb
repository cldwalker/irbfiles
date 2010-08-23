module RailsCore
  def self.append_features(mod)
    super if ENV['RAILS_ENV'] || defined? Rails
  end

  def self.config
    commands = {
      'app'=>{:desc=>'A global app instance to interact with server'},
      'new_session'=>{:desc=>'Creates a new session'},
      'reload!'=>{:desc=>'Reload environment'},
      'helper'=>{:desc=>'Interact with any helper methods'}
    }
    {:commands=>commands}
  end


  if (Rails.version < '3.0' rescue nil)
    # Add route methods *_url and *_path as commands
    def add_routes
      extend ActionController::UrlWriter
      default_url_options[:host] = 'example.com'
    end
  end

  # Execute sql query
  def sql(query)
    ActiveRecord::Base.connection.select_all(query)
  end

  # Execute sql query and format mysql records
  def mysql_sql(query)
    ActiveRecord::Base.connection.execute(query).all_hashes
  end

  # Dumps current schema
  def schema_dump
    ActiveRecord::SchemaDumper.dump ActiveRecord::Base.connection
  end
end
