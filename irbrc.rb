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

Boson.start