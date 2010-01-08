module ::Boson::Scientist
  alias_method :_render_or_raw, :render_or_raw
  def render_or_raw(result)
    if (menu_options = @global_options.delete(:menu))
      filters = @global_options.delete(:filters)
      table = ::Hirb::Helpers::Table.new(result, @global_options)
      result = table.instance_eval("@rows")
      Menu.run(result, menu_options.merge(:filters=>filters), @global_options)
      nil
    else
      # @global_options[:render] = true
      _render_or_raw(result)
    end
  end

  class Menu
    require 'shellwords'
    def self.run(items, options, global_options)
      new(items, options, global_options).run
    end

    def initialize(items, options, global_options)
      @items, @options, @global_options = items, options, global_options
      @fields = @global_options[:fields] ? @global_options[:fields] :
        @global_options[:change_fields] ? @global_options[:change_fields] :
        items[0].is_a?(Hash) ? items[0].keys : [:to_s]
      @options[:default_field] = @options[:default_field] ?
        unalias_field(@options[:default_field]) : @fields[0]
    end

    def run
      input = get_input
      if @options[:shell]
        while input != 'q'
          parse_and_invoke input
          input = get_input
        end
      else
        parse_and_invoke input
      end
    end

    def get_input
      ::Boson.invoke(:menu, @items, :return_input=>true, :fields=>@fields)
    end

    def unalias_field(field)
      @fields.sort_by {|e| e.to_s }.find {|e| e.to_s[/^#{field}/] } || field
    end

    def parse_and_invoke(input)
      cmd, *args = parse_input(input)
      @options[:once] ? invoke(cmd, args.flatten) : args.flatten.each {|e| invoke(cmd, [e]) }
    end

    def invoke(cmd, args)
      if @options[:pretend]
        puts "#{cmd} #{args.inspect}"
      else
        ::Boson.full_invoke cmd, args
      end
    end

    def parse_input(input)
      Shellwords.shellwords(input).map {|word|
        if word[/^(\d(?:[^:]+)?)(?::)?(\S+)?/]
          field = $2 ? unalias_field($2) : @options[:default_field]
          ::Hirb::Util.choose_from_array(@items, $1).map {|e| e[field] }
        else
          word
        end
      }
    end
  end
end

module Menu
end