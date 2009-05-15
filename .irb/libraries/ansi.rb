module Iam::Libraries::Ansi
  # gem install ssoroka-ansi
  def self.init
    require 'ansi'
    colors = [:magenta, :green, :white, :blue, :cyan, :yellow, :black, :purple, :light_blue, :red]
    colors.each do |e|
      self.class_eval %[
        def #{e}(text, options={})
          if options.delete(:bg)
            puts ::ANSI.bg_color(:#{e}, options) { text }
          else
            puts ::ANSI.color(:#{e}, options) { text }
          end
        end
      ]
    end
  end

  def progress(array)
    array.each_with_index {|e,i| 
      printf ANSI.left(50) + "Starting item #{i +1} ..."
      yield 
    }
    print "\n"
  end
end