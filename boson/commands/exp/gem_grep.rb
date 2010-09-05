module Gemgrep
  def self.after_included
    require 'gem_grep'
    require 'rubygems/specification_hack'
  end

  # @render_options :fields=>{:default=>GemGrep.display_fields, :values=>GemGrep.valid_gemspec_columns.map {|e| e.to_sym}}
  # @options :grep_fields=>{:default=>GemGrep.grep_fields, :values=>GemGrep.valid_gemspec_columns}
  def local_grep(*args)
    options = args.pop
    cmd = ::Gem::CommandManager.instance.find_command('grep')
    cmd.results_only = true
    cmd.invoke(*(args + ['-f', options[:grep_fields].join(',')]))
    cmd.results
  end

  # @render_options :fields=>{:default=>GemGrep.display_fields, :values=>GemGrep.valid_gemspec_columns}
  # @options :grep_fields=>{:default=>GemGrep.grep_fields, :values=>GemGrep.valid_gemspec_columns}
  def gem_grep(term, options={})
    GemGrep.grep_fields = options[:grep_fields]

    indexes.map {|index|
      records = index.search(term)
      unique_records = records.map {|e| e.name}.uniq.map {|name|
        records.select {|e| e.name == name }.sort_by {|e| e.version }[-1]
      }
      # versions = records.inject({}) {|t,e| (t[e.name] ||= []) << e.version.to_s; t }
    }.flatten
  end

  private
  def indexes
    @indexes ||= servers.map {|e| GemGrep::Index.new(e).gem_index }
  end

  def servers
    @servers ||= [:gemcutter]
  end
end
