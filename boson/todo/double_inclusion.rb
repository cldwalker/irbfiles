# from http://www.ruby-forum.com/topic/112897#263113
class Module
  alias :old_include :include
  def include other
    old_include other
    if self.class == Module
      this = self
      ObjectSpace.each_object Module do |mod|
        p [mod, this, self] if mod < self
        this.append_features(mod).module_eval do include this end if mod < self
        #mod.module_eval do include this end if mod < self
      end
    end
  end
end

