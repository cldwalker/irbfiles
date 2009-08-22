module Countdown
  def self.included(mod)
    require 'countdown'
  end

  def countdown(question, seconds=10.0, default=false)
    ::Countdown.ask(question, seconds, default)
  end
end
