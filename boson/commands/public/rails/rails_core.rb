module RailsCore
  def self.append_features(mod)
    super if ENV['RAILS_ENV']
  end

  def self.config
    commands = {
      'app'=>{:description=>'A global app instance to interact with server'},
      'new_session'=>{:description=>'Creates a new session'},
      'reload!'=>{:description=>'Reload environment'},
      'helper'=>{:description=>'Interact with any helper methods'}
    }
    {:commands=>commands}
  end

  # Add route methods *_url and *_path as commands
  def add_routes
    extend ActionController::UrlWriter
    default_url_options[:host] = 'example.com'
  end

  # Execute sql query
  def sql(query)
    ActiveRecord::Base.connection.select_all(query)
  end
end
