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
end
