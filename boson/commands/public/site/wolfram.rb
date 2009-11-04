module Wolfram
  def self.included(mod)
    require 'net/http'
    require 'cgi'
  end

  def wolfram(query)
    result = wolfram_query(query)
    result.delete_if {|e| e.nil? || e.empty? }
    if result.size == 2
      puts result[0]
      render result[1].split("\\n").map {|e| e.split(/\s*\|\s*/) }
    else
      render result.map {|e| [e]} rescue result
    end
  end

  private
  # from http://wklej.org/hash/464d6c81c1/ w/ tweaks
  def wolfram_query(query)
    begin
      query = CGI.escape(query)
      res = Net::HTTP.get "www01.wolframalpha.com", "/input/?i="+query
      t = []
      res.each_line{ |i| 
          m = i.match('jsonArray.popups.i_0[1234]00_1 = \{".*?": "(.*?)"' )
          if !m.nil?
              t << m.to_a[1] if m.to_a.length > 0
          end
      }
      return t
    rescue
      puts $!
      return false
    end
  end
end
