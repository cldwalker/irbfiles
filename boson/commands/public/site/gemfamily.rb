module GemFamily
  def self.after_included
    require 'nokogiri'
  end

  # Prints gem dependents
  def gem_family(rubygem)
    doc = Nokogiri::HTML(get("http://gemfamily.info/gems/#{rubygem}"))
    doc.css('div.links')[2].children.css('a').map {|e| e.text }
  end
end
