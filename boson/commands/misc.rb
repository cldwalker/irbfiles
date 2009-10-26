module Misc
  # Reloads a file just as you would require it.
  def reload(require_regex)
    $".grep(/#{require_regex}/).each {|e| $".delete(e) && require(e) }
  end

  # From http://solutious.com/blog/2009/09/22/secret-of-object-to_s/
  # Calculates id found in :to_s of most objects
  def to_s_id(obj)
    "0x%x" % [obj.object_id*2]
  end
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
end