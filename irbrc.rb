# This irbrc provides a simple way to load preferred irb settings via
# a methods in Iam::Libraries or a file under your base directory.

require 'rubygems'
# attempt to load a local hirb gem
begin
  require 'local_gem' # gem install cldwalker-local_gem
  LocalGem.local_require 'hirb' # gem install cldwalker-hirb
rescue LoadError
  require 'hirb' # gem install cldwalker-hirb
end

# attempt to load a local alias gem
begin
  require 'local_gem' # gem install cldwalker-local_gem
  LocalGem.local_require 'alias' # gem install cldwalker-alias
rescue LoadError
  require 'alias' # gem install cldwalker-alias
end

#Set this to your preferred directory
irb_base_dir = "#{ENV['HOME']}/.irb"
irb_base_dir = File.exists?(irb_base_dir) ? irb_base_dir : '.irb'
$:.unshift irb_base_dir
require 'lib/iam'
require 'libraries'

Iam.register(:irb_options, :wirble, :railsrc, :aliases, :history, :local_gem, :core_extensions,
  :tree_commands, Iam::Commands, Hirb::Console, :with=>self)
