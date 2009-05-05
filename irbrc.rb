# This irbrc provides a simple way to load preferred irb settings via
# a methods in Iam::Libraries or a file under your base directory.

require 'rubygems'
#Set this to your preferred directory
irb_base_dir = "#{ENV['HOME']}/.irb"
irb_base_dir = File.exists?(irb_base_dir) ? irb_base_dir : '.irb'
$:.unshift irb_base_dir
require 'lib/iam'
require 'libraries'

Iam.register(:irb_options, :wirble, :railsrc, :aliases, :history, :local_gem, :core_extensions, :method_lister, :hirb, :with=>self)
self.extend Iam
