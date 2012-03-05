# This irbrc uses my irb manager, boson, to load libraries of irb commands + snippets

require 'rubygems' unless ENV['NO_RUBYGEMS']
require 'boson/console'
Boson.start
