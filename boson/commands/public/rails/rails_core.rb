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

  # List model constants
  def models
    tables.map {|e| e.classify.constantize rescue nil }.compact
  end

  # @render_options :change_fields=>[:model, :count]
  # List models and their database counts
  def model_counts
    models.map {|e| [e, e.count] }
  end

  # @render_options :fields=>[:name, :type, :null, :default]
  # List a model's column details
  def model_columns(model)
    filter_model(model).columns
  end

  # @render_options :fields=>[:name, :macro, :options]
  # List a model's relationships
  def model_relationships(model)
    filter_model(model).reflections.values
  end

  # List tables
  def tables
    ActiveRecord::Base.connection.tables
  end

  private
  def filter_model(str)
    return str unless str.is_a?(String)
    str = tables.find {|e| e[/^#{str}/i] } || str unless tables.include?(str)
    begin
      str.classify.constantize
    rescue NameError
      raise "Unable to find model for '#{str}'"
    end
  end
end
