module GoogleReader
  def self.included(mod)
    require 'google/reader'
  end

  def self.after_included
    Google::Reader::Base.establish_connection(ENV["GOOGLE_USER"], ENV["GOOGLE_PASSWORD"])
  end

  # @render_options :fields=>{:default=>[:title, :google_id] }
  # List feeds and their google ids
  def all_feeds
    Google::Reader::Subscription.all
  end
  
  # @render_options :fields=>{:values=>[:google_id, :count], :default=>[:google_id, :count]},
  #   :reverse_sort=>true, :sort=>{:default=>:count}
  # List unread feeds
  def unread_feeds
    Google::Reader::Count.all
  end

  # @render_options {:fields=>{:values=>[:title, :url, :published]}}
  # List latest 20 stories by label
  def stories(label)
    records = Google::Reader::Label.new(label).entries
    records.map {|e| {:title=>e.title, :url=>e.links[0].href, :published=>e.published } }
  end

  # @config :option_command=>true
  # List labels
  def labels(options={})
    Google::Reader::Label.all.map {|e| e.name }
  end
end
