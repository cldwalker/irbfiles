module Gemcutter
  FIELDS = %w{name authors version_downloads info project_uri gem_uri version
    downloads dependencies homepage_uri source_code_uri bug_tracker_uri wiki_uri
    documentation_uri mailing_list_uri}
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

  # @render_options :fields=>{:values=>FIELDS, :default=>%w{name downloads info authors homepage_uri}},
  #  :filters=>{:default=>{'dependencies'=>:inspect}}, :max_fields=>{:default=>{'authors'=>0.15,
  #  'homepage_uri'=>0.10}}
  # @options :page=>{:default=>1, :desc=>'page number'}
  # @config :menu=>{:command=>:browser, :default_field=>'homepage_uri'}
  # Search gemcutter
  def gem_search(*query)
    options = query[-1].is_a?(Hash) ? query.pop : {}
    params = "page=#{options[:page]}&query=#{CGI.escape(query.join(' '))}"
    json_get "http://gemcutter.org/api/v1/search.json?#{params}"
  end

  # @render_options :fields=> { :values => ["authors", "bug_tracker_uri", "dependencies", "documentation_uri",
  #  "downloads", "gem_uri", "homepage_uri", "info", "mailing_list_uri", "name", "project_uri", "source_code_uri",
  #  "version", "version_downloads", "wiki_uri"], :default => ['name', 'version', 'downloads',
  #  'version_downloads', 'dependencies'] }, :sort => 'downloads', :reverse_sort => true
  #  List my gems. You must you know your rubygems api key
  def my_gems(api_key=ENV['RUBYGEMS_API_KEY'])
    json_get "http://rubygems.org/api/v1/gems.json?api_key=#{api_key}"
  end

  # @render_options :fields => [:name, :number, :dependencies]
  # List dependencies of multiple gems
  def gem_resolve(*rubygems)
    Marshal.load(get("http://rubygems.org/api/v1/dependencies?gems=#{rubygems.join(',')}"))
  end

  private
  # Gets a json url and converts it to a ruby object
  def json_get(url)
    get url, :parse=>true
  end
end
