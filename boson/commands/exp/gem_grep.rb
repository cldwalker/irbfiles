module Gemgrep
  def self.included(mod)
    begin
      require 'local_gem'
      LocalGem.local_require 'gem_grep'
    rescue
      require 'gem_grep'
    end
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
end