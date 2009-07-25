module Gemgrep
  def self.included(mod)
    LocalGem.local_require 'gem_grep'
    require 'zlib'
    require 'fileutils'
    require 'lib/rubygems/specification'
  end

  def gem_grep(term, options={})
    setup_marshal_index unless File.exists?(marshal_file)
    GemGrep.grep_fields = GemGrep.parse_input(options[:g]) if options[:g]
    GemGrep.display_fields = GemGrep.parse_input(options[:d]) if options[:d]
    records = gem_index.search(term)
    unique_records = records.map {|e| e.name}.uniq.map {|name|
      records.select {|e| e.name == name }.sort_by {|e| e.version }[-1]
    }
    # versions = records.inject({}) {|t,e| (t[e.name] ||= []) << e.version.to_s; t }
    puts table(unique_records, :fields=>GemGrep.display_fields)
  end

  def gem_index
    @gem_index ||= begin
      puts "Loading large gem index. Patience is a bitch ..."
      temp_index = Marshal.load(File.read(marshal_file))
      temp_index.extend(Gem::SuperSearch)
    end
  end

  def setup_marshal_index(name=nil)
    server = name if name
    download_marshal_index unless File.exists?(marshal_compressed_file)
    File.open(marshal_file, 'w') {|f| f.write Zlib::Inflate.inflate(File.read(marshal_compressed_file)) }
  end

  def download_marshal_index
    puts "Downloading compressed Marshal gemspec index to ~/.gem_grep. Patience is a bitch..."
    FileUtils.mkdir_p("~/.gem_grep")
    system("curl #{marshal_url} > #{marshal_compressed_file}")
  end

  def marshal_file
    File.expand_path "~/.gem_grep/marshal_#{server}"
  end

  def marshal_compressed_file
    File.expand_path "~/.gem_grep/marshal_#{server}.Z"
  end

  def marshal_url
    gem_server[server] + "/Marshal.#{Marshal::MAJOR_VERSION}.#{Marshal::MINOR_VERSION}.Z"
  end

  def gem_server
    {:rubyforge=>"http://gems.rubyforge.org", :github=>"http://gems.github.com"}
  end

  def server
    @server ||= :github
  end

  def server=(name)
    @server = name
  end
end