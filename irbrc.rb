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

Iam.register(:irb_options, :railsrc, :aliases, :history, :local_gem, :core_extensions,
  :wirble, :duration, :utility_belt, :history_commands, :tree_commands,
  Iam::Commands, Hirb::Console,IRB::ExtendCommandBundle, :with=>self)
