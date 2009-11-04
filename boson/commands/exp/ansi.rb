module Ansi
  def self.included(mod)
    require 'ansi' # gem install ssoroka-ansi
  end
  COLORS = [:magenta, :green, :white, :blue, :cyan, :yellow, :black, :purple, :light_blue, :red]

  # @options :background_color=>{:type=>:string, :values=>COLORS}, :color=>{:type=>:string, :values=>COLORS}
  # Prints text in color or background color
  def color(text, options={})
    if (background_color = options.delete(:background_color))
      puts ::ANSI.bg_color(background_color.to_sym, options) { text }
    else
      puts ::ANSI.color((options[:color] || 'blue').to_sym, options) { text }
    end
  end

  # Supposed to indicate in-place progress while iterating over array
  def progress(array)
    array.each_with_index {|e,i| 
      printf ANSI.left(50) + "Starting item #{i +1} ..."
      yield(e)
    }
    print "\n"
  end
end