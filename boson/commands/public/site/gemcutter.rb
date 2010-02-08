module Gemcutter
  FIELDS = %w{name authors version_downloads info project_uri gem_uri version downloads dependencies}
  def self.included(mod)
    require 'json'
    require 'cgi'
  end

  def self.config
    # turn off detecting json's monkeypatched methods
    {:object_methods=>false}
  end

  # @render_options :change_fields=>%w{field value}
  # Lists basic gemcutter stats for gem
  def cut(rubygem)
    json_get("http://gemcutter.org/api/v1/gems/#{rubygem}.json") || puts("Invalid gem '#{rubygem}'")
  end

  # @render_options :fields=>{:values=>FIELDS, :default=>%w{name downloads project_uri info}}
  # @options :sleep=>{:default=>1, :desc=>"Seconds to sleep between api calls"},
  #  :loud=>{:desc=>"Print something between api calls", :type=>:boolean, :default=>true}
  # List multiple gemcutter gems
  def cuts(*rubygems)
    options = rubygems[-1].is_a?(Hash) ? rubygems.pop : {}
    rubygems.inject([]) {|t,e|
      puts "Fetching gem '#{e}'" if options[:loud]
      response = json_get("http://gemcutter.org/api/v1/gems/#{e}.json")
      sleep options[:sleep]
      response.is_a?(Hash) ? t << response : t
    }
  end

  # @render_options :fields=>{:values=>FIELDS, :default=>%w{name downloads info authors}},
  #  :filters=>{:default=>{'dependencies'=>:inspect}}, :max_fields=>{:alias=>false, :default=>{'authors'=>30}}
  # @options :page=>{:default=>1, :desc=>'page number'}
  # Search gemcutter
  def gem_search(*query)
    options = query[-1].is_a?(Hash) ? query.pop : {}
    params = "page=#{options[:page]}&query=#{CGI.escape(query.join(' '))}"
    json_get "http://gemcutter.org/api/v1/search.json?#{params}"
  end

  private
  # Gets a json url and converts it to a ruby object
  def json_get(url)
    (body = get(url, :success_only=>true)) && JSON.parse(body)
  end
end