# API ref: http://forum.brightbox.co.uk/forums/isitruby19-com/topics/api-is-added
module IsItRuby19
  def r19_gem(name)
    table r19_formatted_comments(name), :fields=>%w{version works_for_me platform body name url}
  end

  def r19_stat(name)
    comments = r19_comments(name)
    worked = comments.select {|e| e["works_for_me"] }.size
    stat = comments.size.zero? ? "0" : "#{worked}/#{comments.size} (#{sprintf('%.2f', worked / comments.size.to_f)})"
    {:name=>name, :stat=>stat}
  end

  def r19_stats(names)
    names.map {|e| r19_stat(e) }
  end

  def r19_comments(name)
    get("http://isitruby19.com/#{name}/comments.json").map {|e| e["comment"]}
  rescue
    []
  end

  def r19_formatted_comments(name)
    r19_comments(name).each {|e| e["platform"] = e['platform']['name']; e["body"] = e["body"].gsub(/\r?\n\r?/,";") }
  end
end