# for less dependencies could use http://gist.github.com/122071
module GmailLib
  def self.included(mod)
    # require 'gmail_sender'
    require 'gmail' #ruby-gmail gem
  end

  #@render_options :fields=>[:uid, :body], :filters=>{:default=>{:body=>[:[], /Subject: (.*)\r\n/, 1]}}
  #@options :unread=>true
  def inbox(options={})
    options[:unread] ? gmail.inbox.emails(:unread) : gmail.inbox.emails
  end

  # Send email from your gmail acount. ENV['GOOGLE_USER'] and ENV['GOOGLE_PASSWORD']
  # should be setup.
  # def email(to, subject, body)
  #   gmail.send(to, subject, body)
  # end

  private
  def gmail
    @gmail ||= Gmail.new(ENV['GOOGLE_USER'], ENV['GOOGLE_PASSWORD'])
  end
end