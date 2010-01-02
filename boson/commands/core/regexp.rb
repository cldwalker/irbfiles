module RegexpLib
  # From pickaxe. Shows regexp in a string by quoting it with << >>.
  def show_regexp(regex, string)
     if string =~ regex
        "#{$`}<<#{$&}>>#{$'}"
     else
        "no match"
     end
  end
end
