module RegexpLib
  # From pickaxe. Shows regexp in a string by quoting it with << >>.
  def show_regexp(re, str)
     if str =~ re
        "#{$`}<<#{$&}>>#{$'}"
     else
        "no match"
     end
  end
end