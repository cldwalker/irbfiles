# Inspired loosely by http://gist.github.com/113226
module Watch
  # @options :period=>1, :debug=>:boolean, :command=>:string, :system=>:string
  # @desc Watches paths periodically with :period and executes commands and/or
  # reports paths that have changed
  def watch(*globs)
    options = globs[-1].is_a?(Hash) ? globs.pop : {}
    globs = ['.'] if globs.empty?
    globs.map! {|e| e += '/**/*' unless e =~ /\*|\//; e }
    files = {}
    loop do
      changed = []
      (globbed = Dir.glob(globs)).each do |e|
        ctime = File.ctime(e).to_i
        files[e] ||= ctime
        if ctime != files[e]
          files[e] = ctime
          changed << e
        end
      end

      if !changed.empty?
        puts "These files changed: #{changed.join(', ')}" if options[:debug]
        send(options[:command]) if options[:command]
        system(options[:system]) if options[:system]
      else
        puts "Nothing changed for #{globbed.size} paths in '#{globs.join(',')}'." if options[:debug]
      end
      sleep options[:period]
    end
  end

  private
  def rake_test
    system('rake test')
  end

  def rake_spec
    system('spec spec')
  end
end