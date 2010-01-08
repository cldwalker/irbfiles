module ::Boson::Scientist
  alias_method :_render_or_raw, :render_or_raw
  def render_or_raw(result)
    if (menu_options = @global_options.delete(:menu))
      filters = @global_options.delete(:filters)
      table = ::Hirb::Helpers::Table.new(result, @global_options)
      result = table.instance_eval("@rows")
      menu(result, menu_options.merge(:filters=>filters))
    else
      # @global_options[:render] = true
      _render_or_raw(result)
    end
    nil
  end

  # options :loop, :execute_at_once, :transform_functions
  def menu(items, options={})
    fields = @global_options[:fields] ? @global_options[:fields] :
      @global_options[:change_fields] ? @global_options[:change_fields] :
      items[0].is_a?(Hash) ? items[0].keys : [:to_s]
    options[:default_field] = options[:default_field] ?
      (fields.map {|e| e.to_s }.sort.find {|e| e[/^#{options[:default_field]}/] } ||
        options[:default_field]) : fields[0]

    # p options
    input = Boson.invoke(:menu, items, :return_input=>true, :fields=>fields)
    args = parse_input(items, input)
    execute_command(args, options)
  end

  def execute_command(args, options)
    cmd = args.shift
    args.flatten.each {|e|
      Boson.full_invoke cmd, [e[options[:default_field]]]
    }
  end

  def parse_input(items, input)
    input.split(/\s+/).map {|e|
      e[/^\d+/] ? ::Hirb::Util.choose_from_array(items, e) : e
    }
  end
end

module Menu
end