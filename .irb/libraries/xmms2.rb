module Xmms2
  def self.init
    require 'libraries/hirb'
    require 'hirb/helpers/menu'
  end

  def songs(query)
    table search_songs(query), :fields=>[:track, :title, :time]
  end

  def songs_jump(query)
    results = search_songs(query)
    chosen = ::Hirb::Helpers::Menu.render(results, :fields=>[:track, :title, :time])
    system('xmms2', 'jump', chosen[0][:track].to_s) if chosen.size == 1
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