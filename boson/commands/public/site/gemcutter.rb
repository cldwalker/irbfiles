module Gemcutter
  def self.included(mod)
    require 'httparty'
  end

  # @render_options :change_fields=>%w{field value}
  # Lists basic gemcutter stats for gem
  def cut(rubygem)
    HTTParty.get("http://gemcutter.org/api/v1/gems/#{rubygem}.json")
  end

  # @render_options :fields=>["name", "downloads", "info", "version", "authors", "rubyforge_project"]
  # Lists multiple gemcutter gems + stats
  def cuts(*rubygems)
    rubygems.inject([]) {|t,e|
      response = HTTParty.get("http://gemcutter.org/api/v1/gems/#{e}.json")
      response.is_a?(Hash) ? t << response : t
    }
  end
end
