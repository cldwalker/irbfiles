# Ported from http://github.com/drnic/sake-tasks/tree/master/check
# with option modifications
module Syntax
  # options :verbose=>:boolean, :extension=>'rb'
  # Find all .rb files in the current directory tree and report any syntax errors
  def ruby(options={})
    require 'open3'
    Dir["**/*.#{options[:extension]}"].each do |file|
      next if file.match("vendor/rails")
      next if file.match("vendor/plugins/.*/generators/.*/templates")
      puts file if options[:verbose]
      Open3.popen3("ruby -c #{file}") do |stdin, stdout, stderr|
        error = stderr.readline rescue false
        puts "#{file}:#{(error.match(/on line (\d+)/)[1] + ':') rescue nil} #{error}" if error
        stdin.close rescue false
        stdout.close rescue false
        stderr.close rescue false
      end
    end
  end

  # options :verbose=>:boolean
  # Find all .erb or .rhtml files in the current directory tree and report any syntax errors
  def erb(options={})
    require 'erb'
    require 'open3'
    (Dir["**/*.erb"] + Dir["**/*.rhtml"]).each do |file|
      next if file.match("vendor/rails")
      puts file if options[:verbose]
      Open3.popen3('ruby -c') do |stdin, stdout, stderr|
        stdin.puts(ERB.new(File.read(file), nil, '-').src)
        stdin.close
        error = stderr.readline rescue false
        puts "#{file}:#{(error.match(/on line (\d+)/)[1] + ':') rescue nil} #{error}" if error
        puts error if error
        stdout.close rescue false
        stderr.close rescue false
      end
    end
  end

  # options :verbose=>:boolean
  # Find all .yml files in the current directory tree and report any syntax errors
  def yaml(options={})
    require 'yaml'
    Dir['**/*.yml'].each do |file|
      puts file if options[:verbose]
      next if file.match("vendor/rails")
      begin
        YAML.load_file(file)
      rescue => e
        puts "#{file}:#{(e.message.match(/on line (\d+)/)[1] + ':') rescue nil} #{e.message}"
      end
    end
  end  
end