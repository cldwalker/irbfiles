module Rubypan
  # @render_options :change_fields=>%w{name version}
  # Searches rubypan.org for term
  def rubypan(search)
    require 'uri'
    require 'rubygems/command'
    require 'rubygems/commands/query_command'
    search_uri = ::URI.parse "http://rubypan.org/search.Marshal?q=#{search}"
    data = Gem::RemoteFetcher.fetcher.fetch_path search_uri
    spec_tuples = Marshal.load data
    spec_tuples.map {|e| [e[0][0], e[0][1].to_s]}
  end
end