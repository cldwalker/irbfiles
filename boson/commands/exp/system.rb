# Different ways of implementing system()
module System
  # @options :error=>:boolean
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

  # Execute system command with shell aliasing on
  def sh(*args)
    system %[
      if [ -f ~/.bashrc ]; then source ~/.bashrc; fi
      shopt -s expand_aliases
      #{args.join(' ')}
    ]
  end

  # @options :screen=>:boolean, :print=>:boolean, :return=>:string, :pretend=>false
  def new_system(*args)
    options = (args[-1].is_a?(Hash)) ? args.pop : {}
    command = args[0]
    command = "screen #{command}" if options[:screen]
    puts "shell: '#{command}'" if options[:print] or options[:pretend]
    return nil if options[:pretend]
    if options[:return]
      cmd_output = `#{command}`
      if options[:return] == :array
        return_value = cmd_output.split("\n")
      #string (true, normal?) or pager
      else
        return_value = cmd_output

        if options[:return] == :pager && return_value.respond_to?(:|)
          return_value.|()
          return_value = nil
        end
      end
    #return-boolean, output- stdout
    else
      return_value = system(command)
    end

    return_value
  end

end
