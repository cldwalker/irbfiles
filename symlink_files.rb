#!/usr/bin/env ruby

require 'fileutils'
home = File.expand_path('~')

FileUtils.ln_s(File.join(Dir.pwd,'irbrc.rb'), File.join(home,'.irbrc'), :verbose=>true, :force=>true)
FileUtils.ln_s(File.join(Dir.pwd,'.irb'), File.join(home,'.irb'), :verbose=>true, :force=>true)
