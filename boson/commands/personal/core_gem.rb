module CoreGem
  # my ruby extensions: http://github.com/cldwalker/my_core
  # use core to load extensions: http://github.com/cldwalker/core
  def self.included(mod)
    require 'local_gem'
    %w{core}.each do |e|
      begin
        LocalGem.local_require e
      rescue Exception
        require e
      end
    end
  end

  def self.disabled
    #::Core.default_library = MyCore
    libraries = {
      :activesupport=>{:base_class=>"ActiveSupport::CoreExtensions", :base_path=>"active_support/core_ext"},
      :facets=>{:base_path=>"facets", :monkeypatch=>true},
      :nuggets=>{:base_path=>"nuggets", :monkeypatch=>true}
    }
    libraries.each do |k,v|
      ::Core.create_library(v)
    end

    # eval %[module ::Util; end]
    #Core.verbose = true
    conf = {
      Object=>{:only=>:instance},
      Dir=>{:only=>:class},
      File=>{:only=>:class},
      IO=>{:only=>:class},
    }
    conf.each do |k,v|
      ::Core.extends k, v
    end

    [Array, Module, Class, Hash, Regexp, String].each do |e|
      ::Core.extends e
    end
  end  
end
