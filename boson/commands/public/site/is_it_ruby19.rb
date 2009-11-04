# API ref: http://forum.brightbox.co.uk/forums/isitruby19-com/topics/api-is-added
module IsItRuby19
  def self.config
    {:namespace=>'r19', :dependencies=>['httparty']}
  end

  # @render_options :fields=>{:values=>%w{version works_for_me platform body name url}}
  # List all comments for a given gem
  def gem(name)
    comment_feed(name).each {|e| e["platform"] = e['platform']['name']; e["body"] = e["body"].gsub(/\r?\n\r?/,";") }
  end

  # @render_options :fields=>[:name, :stat]
  # Compares given gems by % of users that report success with gems
  def gems(*names)
    names.map {|e| stat(e) }
  end

  private
  def stat(name)
    comments = comment_feed(name)
    worked = comments.select {|e| e["works_for_me"] }.size
    stat = comments.size.zero? ? "0" : "#{worked}/#{comments.size} (#{sprintf('%.2f', worked / comments.size.to_f)})"
    {:name=>name, :stat=>stat}
  end

  def comment_feed(name)
    get("http://isitruby19.com/#{name}/comments.json").map {|e| e["comment"]}
  rescue
    []
  end
end