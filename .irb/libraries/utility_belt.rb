module Iam::Libraries::UtilityBelt
  def self.init
    gem "utility_belt"
    require 'utility_belt/equipper'
    # extensions: hash_math, with, string_to_proc, pipe
    UtilityBelt.equip(:not, :language_greps, :irb_verbosity_control, :clipboard, :interactive_editor)
  end
  
  def clipboard_copy(stuff)
    UtilityBelt::Clipboard.write(stuff)
  end
  
  def clipboard_paste
    UtilityBelt::Clipboard.read
  end
end