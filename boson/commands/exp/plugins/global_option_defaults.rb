class ::Boson::OptionCommand
  alias_method :_set_global_option_defaults, :set_global_option_defaults
  def set_global_option_defaults(opts)
    opts = _set_global_option_defaults(opts)
    if opts[:fields][:values]
      opts[:filters][:keys] ||= opts[:fields][:values]
      opts[:max_fields][:keys] ||= opts[:fields][:values]
    end
    opts
  end
end