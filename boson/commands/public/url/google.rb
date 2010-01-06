module GoogleUrl
  # Opens google analytics for given date range
  def analytics_day(start_date=nil, end_date=nil)
    start_date = start_date ? Date.parse("#{start_date}/2010") : Date.today
    start_date = start_date.strftime("%Y%m%d")
    end_date ||= start_date
    "https://www.google.com/analytics/reporting/?reset=1&id=14680769&pdr=#{start_date}-#{end_date}"
  end

  # Posts by label
  def reader_label(label)
    "http://www.google.com/reader/view/user/-/label/#{label}"
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
    require 'cgi'
    "http://google.com/search?q=#{CGI.escape(query.join(' '))}"
  end

  # @options :zip=>:numeric
  # @config :alias=>'gmv'
  def google_movies(options={})
    "http://www.google.com/movies?near=#{options[:zip]}"
  end

  # @config :alias=>'map'
  # Map search
  def google_maps(*query)
    require 'cgi'
    "http://maps.google.com/maps?q=#{CGI.escape(query.join(' '))}"
  end

  # @config :alias=>'gm'
  def google_mail
    "https://mail.google.com/mail/#inbox"
  end
end