# from defunkt's hub gem which is really from 
# http://nex-3.com/posts/73-git-style-automatic-paging-in-ruby
module PagerLib
  # Aggregates all future calls to STDOUT and for less conditionally pages them
  def run_pager
    return if PLATFORM =~ /win32/
    return unless $stdout.tty?

    read, write = IO.pipe

    if Kernel.fork
      # Parent process, become pager
      $stdin.reopen(read)
      read.close
      write.close

      # Don't page if the input is short enough
      ENV['LESS'] = 'FSRX'
      # Wait until we have input before we start the pager
      Kernel.select [STDIN]

      pager = ENV['PAGER'] || 'less'
      exec pager rescue exec "/bin/sh", "-c", pager
    else
      # Child process
      $stdout.reopen(write)
      $stderr.reopen(write) if $stderr.tty?
      read.close
      write.close
    end
  end
end
