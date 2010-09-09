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

  # List migrations in db
  def db_migrations
    sql('select * from schema_migrations').map {|e| e['version'] }
  end

  # Lists migrations in db/migrate
  def file_migrations
    Dir['db/migrate/*.rb'].inject({}) {|h,e|
      e =~ /(\d+)_([^\/]+)$/
      h[$1] = $2 if $1 && $2; h
    }
  end

  # Lists file migrations that aren't in db
  def td_migrations
    file_migrations.keys - db_migrations
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

  # @render_options :fields=>[:model, :name, :type, :null, :default]
  # @options :model=>:string
  # List all or a model's column details
  def model_columns(options={})
    mds = options[:model] ? Array(filter_model(options[:model])) : models
    mds.map {|e|
      e.columns.map {|o|
        o.instance_eval %[def model; #{e.to_s.inspect}; end]
        o
      }
    }.flatten
  end

  # @render_options :fields=>[:name, :macro, :options]
  # List a model's relationships
  def model_relationships(model)
    filter_model(model).reflections.values
  end

  # @render_options :fields=>[:type, :raw_filter, :kind, :options, :filter]
  # @options :types=>[:commit, :create, :destroy, :find, :initialize, :rollback, :save, :touch,
  #   :update, :validate, :validation]
  # List a model's callbacks
  def model_callbacks(model, options={})
    raise "Only for Rails >= 3" unless ::Rails.version >= '3.0'
    options[:types].map {|type|
      filter_model(model).send("_#{type}_callbacks").map {|o|
        o.instance_eval %[def type; #{type.inspect}; end]
        o
      }
    }.flatten
  end

  # @render_options :fields=>[:kind, :method, :options]
  # @options :types=>[:after_validation_on_update, :before_destroy, :validate_on_create,
  #   :after_destroy, :validate_on_update, :after_find, :after_initialize, :before_save, :after_save,
  #   :before_create, :after_create, :before_update, :validate, :after_update, :before_validation,
  #   :after_validation, :before_validation_on_create, :after_validation_on_create, :before_validation_on_update]
  # List a model's validations
  def model_chains(model, options={})
    raise "Only for Rails <= 3" unless ::Rails.version <= '3.0'
    options[:types].map {|type|
      filter_model(model).send("#{type}_callback_chain")
    }.flatten
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
