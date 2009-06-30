module Shell
  def self.included(mod)
    require 'open3'
  end

  def shell(*args)
    stdin, stdout, stderr = Open3.popen3(*args)
    stdout.read
  end

  # doesn't work for invalid commands
  def backtick(cmd,*args)
    ::IO.popen('-') {|f| f ? f.read : exec(cmd,*args)}
  end
end