# copied from somewhere
module Page
  class IRBLess
    def setup_pager
      for pager in [ ENV['PAGER'], "less", "more", 'pager' ].compact.uniq
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

  def page(str, pager=nil)
    pager ||= IRBLess.new
    pager.less(str)
  end
end
