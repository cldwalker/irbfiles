# This irbrc uses my irb manager, boson, to load libraries of irb commands + snippets

require 'rubygems' unless ENV['NO_RUBYGEMS']
require 'boson'
require 'boson/console' if Boson::VERSION >= '0.5.0'
Boson.start
