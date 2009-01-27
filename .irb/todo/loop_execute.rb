#from http://po-ru.com/diary/iterative-development-in-irb/
def loop_execute(file)
  old_mtime = nil
  loop do
    # print("\e[sWaiting...")
    sleep(0.2) while (mtime = File.stat(file).mtime) == old_mtime
    # print("\e[u\e[K")
    begin
      r = eval(File.read(file))
      puts("=> #{r.inspect}")
    rescue IRB::Abort
      puts("Abort")
      return
    rescue Exception => e
      puts("#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
    end
    old_mtime = mtime
  end
end
