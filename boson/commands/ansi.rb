module Ansi
  def self.included(mod)
    require 'ansi' # gem install ssoroka-ansi
  end

  options :list=>:boolean, :background_color=>:optional, :color=>:optional
  # Prints text in color or background color
  def color(text, options={})
    if options.delete(:list)
      colors = [:magenta, :green, :white, :blue, :cyan, :yellow, :black, :purple, :light_blue, :red]
    elsif (background_color = options.delete(:background_color))
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