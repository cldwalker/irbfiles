module CodeStats
  # @render_options :change_fields=>%w{field value}
  # Displays code stats for a ruby directory: method count, loc, class count
  def code_stats(dir='lib')
    require 'code_statistics'
    CodeStatistics.new([dir]).instance_variable_get("@statistics")[dir]
  end

  # @config :alias=>'loc'
  # @render_options :change_fields=>%w{file loc}
  # Line count per file for ruby files
  def lines_of_code(dir='lib')
    Dir.glob(dir+"/**/*.rb").map {|e| [e, File.readlines(e).size ] }
  end
end
