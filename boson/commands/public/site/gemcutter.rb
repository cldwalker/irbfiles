module Gemcutter
  FIELDS = %w{name authors version_downloads info project_uri gem_uri version downloads}
  def self.included(mod)
    require 'json'
  end

  # @render_options :change_fields=>%w{field value}
  # Lists basic gemcutter stats for gem
  def cut(rubygem)
    json_get "http://gemcutter.org/api/v1/gems/#{rubygem}.json"
  end

  # @render_options :fields=>{:values=>FIELDS, :default=>%w{name downloads project_uri info}}
  # Lists multiple gemcutter gems + stats
  def cuts(*rubygems)
    rubygems.inject([]) {|t,e|
      response = json_get("http://gemcutter.org/api/v1/gems/#{e}.json")
      response.is_a?(Hash) ? t << response : t
    }
  end

  # @render_options :fields=>{:values=>FIELDS, :default=>%w{name downloads project_uri info}}
  # @options :page=>1
  # @config :alias=>'cs'
  # Searches gemcutter
  def cut_search(query, options={})
    json_get "http://gemcutter.org/api/v1/search.json?page=#{options[:page]}&query=#{query}"
  end

  # Gets a json url and converts it to a ruby object
  def json_get(url)
    JSON.parse get(url)
  end
end
