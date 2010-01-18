module Xmms2
  # @render_options :fields=>{:default=>[:track, :title, :time]}
  # @options :menu=>true
  # @config :menu=>{:command=>'play_track'}
  # Searches for songs, displays results in menu and lets you jump to chosen song
  def songs_jump(query, options={})
    results = search_songs(query)
    if options[:menu]
      if (chosen = menu(results, :fields=>[:track, :title, :time], :validate_one=>true))
        system('xmms2', 'jump', chosen[:track].to_s)
      end
    else
      results
    end
  end

  # Plays everything under a given directory
  def play(*dirs)
    system('xmms2 clear')
    dirs.unshift 'xmms2', 'radd'
    system(*dirs)
    system('xmms2 shuffle')
  end

  private
  def search_songs(query, options={})
    parse_songs `xmms2 list |grep #{query}`.split("\n")
  end

  def parse_songs(songs)
    songs.map {|e|
      (e =~ /^\s*\[(\d+).*?\] (.*?)\((\d\d:\d\d)\)/) ? 
        {:track=>$1.to_i, :title=>$2, :time=>$3} : nil
    }.compact
  end
end