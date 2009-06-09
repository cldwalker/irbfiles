module UtilityBelt
  def self.included(mod)
    gem "utility_belt"
    require 'utility_belt/equipper'
    # extensions: hash_math, with, string_to_proc, pipe, not
    ::UtilityBelt.equip(:clipboard)
  end
  
  def clipboard_copy(stuff)
    ::UtilityBelt::Clipboard.write(stuff)
  end
  
  def clipboard_paste
    ::UtilityBelt::Clipboard.read
  end
end