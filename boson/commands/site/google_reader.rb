module GoogleReader
  def self.included(mod)
    require 'google/reader'
    Google::Reader::Base.establish_connection(ENV["GOOGLE_USER"], ENV["GOOGLE_PASSWORD"])
  end
  
  def feeds(search=nil, field='google_id')
    results = search ? Google::Reader::Subscription.all.select {|e| e.send(field) =~ /#{search}/ } : Google::Reader::Subscription.all
  end
  
  def open_feed(google_feed)
    browser("http://www.google.com/reader/view/#stream/" + google_feed)
  end

  def open_label(label)
    browser("http://www.google.com/reader/view/user/-/label/"+label)
  end

  def labels
    Google::Reader::Label.all.map {|e| e.name }
  end

  def unread
    Google::Reader::Count.all
  end

  def analytics_day(start_date=nil, end_date=nil)
    start_date = start_date ? Date.parse("#{start_date}/2009") : Date.today
    start_date = start_date.strftime("%Y%m%d")
    end_date ||= start_date
    url = "https://www.google.com/analytics/reporting/?reset=1&id=14680769&pdr=#{start_date}-#{end_date}"
    browser url
  end
end