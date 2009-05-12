module Iam::Libraries::GoogleReader
  def self.init
    require 'google/reader'
    Google::Reader::Base.establish_connection(ENV["GOOGLE_USER"], ENV["GOOGLE_PASSWORD"])
  end
  
  def feeds(search=nil, field='google_id')
    require 'hirb'
    results = search ? Google::Reader::Subscription.all.select {|e| e.send(field) =~ /#{search}/ } : Google::Reader::Subscription.all
    puts Hirb::Helpers::AutoTable.render(results, :fields=>[:title, :google_id])
  end

  def labels
    Google::Reader::Label.all.map {|e| e.name }
  end

  def unread
    Google::Reader::Count.all
  end
end