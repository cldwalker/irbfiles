# This irbrc uses my irb manager, iam, to load libraries of irb commands + snippets

require 'rubygems'
%w{hirb alias iam}.each do |e|
  # load a local gem first or default to normal gem
  begin
    require 'local_gem' # gem install cldwalker-local_gem
    LocalGem.local_require e
  rescue LoadError
    require e # gem install cldwalker-#{e}
  end
end

Iam.register(:irb_features, :local_gem, :core, :wirble, :utility_belt, :irb_history, :tree,
 :hirb, :misc, :method_lister, :every, :with=>self)
