module Misc
  # Hash of class dependencies excluding error-related ones
  def dependencies
    deps = {}
    ObjectSpace.each_object Class do |mod|
      next if mod.name =~ /Errno/
      next if mod < Exception
      deps[mod.to_s] = mod.superclass.to_s
    end
    # dependencies.inject({}) {|h,(k,v)| (h[v] ||= []) << k; h }
    deps
  end

  # Explained http://tagaholic.blogspot.com/2009/01/simple-block-to-hash-conversion-for.html
  # Converts a block definition into a hash
  def block_to_hash(block=nil)
    require 'open_struct'
    config = OpenStruct.new
    if block
      block.call(config)
      config.instance_variable_get("@table")
    else
      {}
    end
  end
end