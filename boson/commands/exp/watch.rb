# Inspired loosely by http://gist.github.com/113226
module Watch
  #@options :period=>1
  # Watches paths periodically with :period and reports paths that have changed
  def watch(glob, options={})
    glob += '/**/*' unless glob =~ /\*|\//
    files = {}
    loop do
      changed = []
      (globbed = Dir[glob]).each do |e|
        ctime = File.ctime(e).to_i
        files[e] ||= ctime
        if ctime != files[e]
          files[e] = ctime
          changed << e
        end
      end

      if !changed.empty?
        message = "These files changed: #{changed.join(', ')}"
        puts message
      else
        puts "Nothing changed for #{globbed.size} paths in '#{glob}'."
      end

      sleep options[:period]
    end
  end
end