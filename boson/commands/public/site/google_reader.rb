module GoogleReader
  def self.included(mod)
    require 'google/reader'
  end

  def self.after_included
    Google::Reader::Base.establish_connection(ENV["GOOGLE_USER"], ENV["GOOGLE_PASSWORD"])
  end

  # @render_options :fields=>{:default=>[:title, :google_id] }
  # @options :query_field=>{:values=>%w{google_id title}, :default=>'google_id'}
  # List feeds and their google ids
  def all_feeds(search=nil, options={})
    feeds = Google::Reader::Subscription.all
    search ? feeds.select {|e| e.send(options[:query_field]) =~ /#{search}/ } : feeds
  end
  
  # @render_options :fields=>{:values=>[:google_id, :count], :default=>[:google_id, :count]}
  # List unread feeds
  def unread_feeds
    Google::Reader::Count.all
  end

  # @render_options {:fields=>{:values=>[:title, :url, :published]}}
  # @options :offset=>:numeric
  # List latest 20 stories by label
  def stories(label)
    records = Google::Reader::Label.new(label).entries
    records.map {|e| {:title=>e.title, :url=>e.links[0].href, :published=>e.published } }
  end

  # @options :menu=>{:type=>:boolean, :desc=>"Choose labels to open in browser"}
  # List labels
  def labels(options={})
    results = Google::Reader::Label.all.map {|e| e.name }
    options[:menu] ? menu(results) {|e| open_label(e[0]) } : results
  end

  private
  def open_feed(google_feed)
    browser("http://www.google.com/reader/view/#stream/" + google_feed)
  end

  def open_label(label)
    browser("http://www.google.com/reader/view/user/-/label/"+label)
  end
end