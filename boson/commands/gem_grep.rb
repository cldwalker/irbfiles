module Gemgrep
  def self.included(mod)
    LocalGem.local_require 'gem_grep'
    require 'rubygems/specification_hack'
  end

  def gem_grep(term, options={})
    GemGrep.grep_fields = GemGrep.parse_input(options[:g]) if options[:g]
    GemGrep.display_fields = GemGrep.parse_input(options[:d]) if options[:d]

    total_records = indexes.map {|index|
      records = index.search(term)
      unique_records = records.map {|e| e.name}.uniq.map {|name|
        records.select {|e| e.name == name }.sort_by {|e| e.version }[-1]
      }
      # versions = records.inject({}) {|t,e| (t[e.name] ||= []) << e.version.to_s; t }
    }.flatten
    render total_records, :fields=>GemGrep.display_fields
  end

  def indexes
    @indexes ||= servers.map {|e| GemGrep::Index.new(e).gem_index }
  end

  def servers
    @servers ||= [:github]
  end

  def rubypan(search)
    require 'uri'
    require 'rubygems/command'
    require 'rubygems/commands/query_command'
    search_uri = ::URI.parse "http://rubypan.org/search.Marshal?q=#{search}"
    data = Gem::RemoteFetcher.fetcher.fetch_path search_uri
    spec_tuples = Marshal.load data
    records = spec_tuples.map {|e| [e[0][0], e[0][1].to_s]}
    render records, :headers=>['name', 'version']
  end
end