# This irbrc uses my irb manager, boson, to load libraries of irb commands + snippets

require 'rubygems'
%w{hirb alias boson}.each do |e|
  # load a local gem first or default to normal gem
  begin
    require 'local_gem' # gem install cldwalker-local_gem
    LocalGem.local_require e
  rescue LoadError
    require e # gem install cldwalker-#{e}
  end
end

# autoload libraries of top level commands
class << Boson.main_object
  def method_missing(method, *args, &block)
    Boson::Index.read
    if lib = Boson::Index.find_library(method.to_s, nil)
      Boson::Library.load_library lib, :verbose=>true
      send(method, *args, &block) if respond_to?(method)
    else
      super
    end
  end
end

Boson.start :verbose=>true
