# from http://github.com/aquabu/irbivore
module Midi
  def self.included(mod)
    require 'midiator'
  end

  # @config :default_option=>'note'
  # @options :note=>{:type=>:numeric, :required=>true},:duration=>0.1, :channel=>0, :velocity=>100
  # Play midi note
  def note(options={})
    Midi.client.play *options.values_at(:note, :duration, :channel, :velocity)
    true
  end

  def self.client
    @client ||= begin
      obj = MIDIator::Interface.new
      obj.use :dls_synth
      obj.instruct_user!
      obj.instruct_user!
      @bpm = 120
      obj
    end
  end
end
