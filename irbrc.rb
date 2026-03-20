# This irbrc uses my irb manager, boson, to load libraries of irb commands + snippets

require 'rubygems' unless ENV['NO_RUBYGEMS']

begin
    # TODO: Remove when boson fixes File.exists?
    require 'file_exists'
    require 'boson/console'
    Boson.start
rescue LoadError
    puts "Skipping boson. Likely due to being in a bundled environment"
end