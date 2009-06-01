module Rails
  module Misc
    def generate(*args)
      ActionController::Routing::Routes.generate(*args)
    end

    def recognize_path(*args)
      ActionController::Routing::Routes.recognize_path(*args)
    end

    def reconnect
      ActiveRecord::Base.connection.reconnect!
    end
  end
end