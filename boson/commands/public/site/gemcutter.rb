module Gemcutter
  def self.included(mod)
    require 'httparty'
  end

  # @render_options :change_fields=>%w{field value}
  # Lists basic gemcutter stats for gem
  def cut(gem_name)
    HTTParty.get("http://gemcutter.org/api/v1/gems/#{gem_name}.json")
  end

  # @render_options :fields=>["name", "downloads", "info", "version", "authors", "rubyforge_project"]
  # Lists multiple gemcutter gems + stats
  def cuts(*gems)
    gems.inject([]) {|t,e| t << HTTParty.get("http://gemcutter.org/api/v1/gems/#{e}.json") }
  end
end
