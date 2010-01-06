module GoogleUrl
  # Opens google analytics for given date range
  def analytics_day(start_date=nil, end_date=nil)
    start_date = start_date ? Date.parse("#{start_date}/2010") : Date.today
    start_date = start_date.strftime("%Y%m%d")
    end_date ||= start_date
    "https://www.google.com/analytics/reporting/?reset=1&id=14680769&pdr=#{start_date}-#{end_date}"
  end

  def reader_label(label)
    "http://www.google.com/reader/view/user/-/label/#{label}"
  end
end