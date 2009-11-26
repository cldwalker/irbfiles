class IRBLess
  def setup_pager
    #for pager in [ ENV['PAGER'], "less", "more", 'pager' ].compact.uniq
    for pager in ['less -r'].compact.uniq
      return IO.popen(pager, "w") rescue nil
    end
  end
  def less(obj)
    pager = setup_pager
    begin
      save_stdout = STDOUT.clone
      STDOUT.reopen(pager)    
      puts obj
    ensure
     STDOUT.reopen(save_stdout)
     save_stdout.close
     pager.close
    end
  end
end

class Object
  def |(pager=nil)
    pager ||= get_default_pager
    if pager.is_a?(IRBLess)
      pager.less(self)
    end
  end
end
 

#could also modify methods to Fixnum,Nil
class Array
  alias :orig_bar |
  def |(pager=nil)
    pager ||= get_default_pager
    if pager.is_a?(IRBLess)
      pager.less(self)
    else
      orig_bar(pager)
    end
  end
end

def get_default_pager
   IRBLess.new
end

