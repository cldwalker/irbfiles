rails_dirname = File.basename(Dir.pwd)
IRB.conf[:PROMPT] ||= {}
IRB.conf[:PROMPT][:RAILS] = {
  :PROMPT_I => "#{rails_dirname}> ",
  :PROMPT_N => "#{rails_dirname}> ",
  :PROMPT_S => "#{rails_dirname}* ",
  :PROMPT_C => "#{rails_dirname}? ",
  :RETURN => "=> %s\n"
}
IRB.conf[:PROMPT_MODE] = :RAILS
