module GoogleUrl
  def self.after_included
    require 'cgi'
  end

  # @options :end_date=>:string, :id=>14680769,
  #  :subpage=>{:values=>%w{top_content referring_sources keywords},:type=>:string}
  # Opens google analytics for given date range
  def google_analytics(start_date=nil, options={})
    start_date = start_date ? Date.parse("#{start_date}/2011") : Date.today
    start_date = start_date.strftime("%Y%m%d")
    end_date = options[:end_date] || start_date
    build_url "https://www.google.com/analytics/reporting/#{options[:subpage] || ''}",
      :id=>options[:id], :pdr=>"#{start_date}-#{end_date}", :trows=>25
  end

  # Posts by label
  def reader_label(label)
    "http://www.google.com/reader/view/user/-/label/#{label}"
  end

  def reader_feed(feed)
    "http://www.google.com/reader/view/#stream/" + CGI.escape(feed)
  end

  # @options :query=>:string
  # @config :alias=>'gr'
  # Open google reader or search within
  def reader(options={})
    url = "http://www.google.com/reader/view"
    options[:query] ? "#{url}/#search/#{options[:query]}" : url
  end

  # @config :alias=>'gs'
  # Basic google search
  def google_search(*query)
    build_url "http://google.com/search", :q=>query
  end

  # @options :zip=>:numeric
  # @config :alias=>'gmv'
  def google_movies(options={})
    "http://www.google.com/movies?near=#{options[:zip]}"
  end

  # @config :alias=>'map'
  # Map search
  def google_maps(*query)
    build_url "http://maps.google.com/maps", :q=>query
  end

  # @config :alias=>'gm'
  def google_mail
    "https://mail.google.com/mail/#inbox"
  end
end
