# from http://github.com/akitaonrails/utility-belt/blob/bdf51947645a44cb96ed00cc5dcb18a62a07ccc0/lib/utility_belt/pastie.rb
module Pastie
  # @options :file=>:boolean
  # Paste string to pastie
  def pastie(string, options={})
    string = File.read(string) if options[:file]
    post("http://pastie.org/pastes/create",
      {"paste_parser" => "ruby", "paste[authorization]" => "burger","paste[body]" => string}).
      body.match(/href="([^\"]+)"/)[1]
  end
end