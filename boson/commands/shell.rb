module Shell
  options :error=>:boolean
  # Returns stdout or stderr string from shell command
  def shell(*args)
    require 'open3'
    options = args[-1].is_a?(Hash) ? args.pop : {}
    stdin, stdout, stderr = Open3.popen3(*args)
    options[:error] ? stderr.read : stdout.read
  end

  # doesn't work for invalid commands
  # Returns string output of command like `` but without having to quote cmd arguments
  def backtick(cmd,*args)
    ::IO.popen('-') {|f| f ? f.read : exec(cmd,*args)}
  end
end