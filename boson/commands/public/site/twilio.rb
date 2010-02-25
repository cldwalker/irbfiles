module TwilioLib
  def self.included(mod)
    require 'twilio'
  end

  # @options :number=>{:default=>ENV['TWILIO_CALLER_ID'], :required=>true, :type=>:string},
  #  :token=>{:default=>ENV['TWILIO_TOKEN'], :required=>true, :type=>:string},
  #  :sid=>{:default=>ENV['TWILIO_SID'], :required=>true, :type=>:string},
  #  :caller_id=>{:default=>ENV['TWILIO_CALLER_ID'], :required=>true, :type=>:string}
  # Call someone through twilio
  def phone(*message)
    options = message[-1].is_a?(Hash) ? message.pop : {}
    Twilio.connect options[:sid], options[:token]
    post_url = build_url 'http://quiet-winter-87.heroku.com/', :message=>message
    Twilio::Call.make options[:caller_id], options[:number], post_url
  end

  # @options :number=>{:default=>ENV['TWILIO_CALLER_ID'], :required=>true, :type=>:string},
  #  :token=>{:default=>ENV['TWILIO_TOKEN'], :required=>true, :type=>:string},
  #  :sid=>{:default=>ENV['TWILIO_SID'], :required=>true, :type=>:string},
  #  :caller_id=>{:default=>ENV['TWILIO_CALLER_ID'], :required=>true, :type=>:string}
  # Text someone through twilio
  def txt(*message)
    options = message[-1].is_a?(Hash) ? message.pop : {}
    Twilio.connect options[:sid], options[:token]
    Twilio::Sms.message options[:caller_id], options[:number], message.join(' ')
  end
end