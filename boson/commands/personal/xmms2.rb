module Xmms2
  # @render_options :fields=>{:default=>[:track, :title, :time]}
  # @config :alias=>'ss', :menu=>{:command=>'play_track', :render=>{:ask=>false}}
  # Searches for songs, displays results in menu and lets you jump to chosen song
  def search_songs(query, options={})
    parse_songs `xmms2 list |grep #{query}`.split("\n")
  end

  # Plays everything under a given directory
  def play(*dirs)
    system('xmms2 clear')
    dirs.unshift 'xmms2', 'radd'
    system(*dirs)
    system('xmms2 shuffle')
  end

  private
  def play_track(track)
    system('xmms2', 'jump', track.to_s)
  end

  def parse_songs(songs)
    songs.map {|e|
      (e =~ /^\s*\[(\d+).*?\] (.*?)\((\d\d:\d\d)\)/) ? 
        {:track=>$1.to_i, :title=>$2, :time=>$3} : nil
    }.compact
  end
end