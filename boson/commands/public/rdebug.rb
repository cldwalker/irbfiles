# from http://simple-and-basic.com/2009/02/catching-and-examining-exceptions-in-a-irb-session.html
module Rdebug
  def post_mortem
    require 'ruby-debug'
    Debugger.start
    #Debugger.run_init_script(StringIO.new)
    Debugger.post_mortem do 
      yield
    end
    Debugger.stop
  end
end
