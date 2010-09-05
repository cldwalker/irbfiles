module Misc
  # Reloads a file just as you would require it
  def reload(require_regex)
    $".grep(/#{require_regex}/).each {|e| $".delete(e) && require(e) }
  end

  # Reloads or requires
  def reload_or_require(require_regex)
    require require_regex if reload(require_regex).size.zero?
  end

  # From http://solutious.com/blog/2009/09/22/secret-of-object-to_s/
  # Calculates id found in :to_s of most objects
  def to_s_id(obj)
    "0x%x" % [obj.object_id*2]
  end
end
