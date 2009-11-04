# for less dependencies could use http://gist.github.com/122071
module Gmail
  def self.included(mod)
    require 'gmail_sender'
  end

  # Send email from your gmail acount. ENV['GOOGLE_USER'] and ENV['GOOGLE_PASSWORD']
  # should be setup.
  def email(to, subject, body)
    gmail.send(to, subject, body)
  end

  private
  def gmail
    @gmail ||= GmailSender.new(ENV['GOOGLE_USER'], ENV['GOOGLE_PASSWORD'])
  end
end