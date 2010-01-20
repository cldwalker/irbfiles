class ::Boson::OptionCommand
  BASIC_OPTIONS[:global] = {:type=>:string, :desc=>"Pass a string of global options without the dashes"}

  alias_method :_parse_global_options, :parse_global_options

  def parse_global_options(args)
    global_options = _parse_global_options(args)
    if global_options[:global]
      global_opts = Shellwords.shellwords(global_options[:global]).map {|str|
        ((str[/^(.*?)=/,1] || str).length > 1 ? "--" : "-") + str }
      global_options.merge! option_parser.parse(global_opts)
    end
    global_options
  end
end