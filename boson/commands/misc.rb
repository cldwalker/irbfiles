module Misc
  # Reloads a file just as you would require it.
  def reload(require_regex)
    $".grep(/#{require_regex}/).each {|e| $".delete(e) && require(e) }
  end
end