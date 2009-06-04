# for less dependencies could use http://gist.github.com/122071
module Gmail
  def self.init
    require 'gmail_sender'
  end

  def email(to, subject, body)
    gmail.send(to, subject, body)
  end

  def gmail
    @gmail ||= GmailSender.new(ENV['GOOGLE_USER'], ENV['GOOGLE_PASSWORD'])
  end
end