module Xmms2
  def songs(query)
    render search_songs(query), :fields=>[:track, :title, :time]
  end

  def songs_jump(query)
    results = search_songs(query)
    if (chosen = menu(results, :fields=>[:track, :title, :time], :validate_one=>true))
      system('xmms2', 'jump', chosen[:track].to_s)
    end
  end

  def play(*dirs)
    system('xmms2 clear')
    dirs.unshift 'xmms2', 'radd'
    system(*dirs)
    system('xmms2 shuffle')
  end

  private
  def search_songs(query)
    parse_songs `xmms2 list |grep #{query}`.split("\n")
  end

  def parse_songs(songs)
    songs.map {|e|
      (e =~ /^\s*\[(\d+).*?\] (.*?)\((\d\d:\d\d)\)/) ? 
        {:track=>$1.to_i, :title=>$2, :time=>$3} : nil
    }.compact
  end
end