module ::Boson::Scientist
  alias_method :_render_or_raw, :render_or_raw
  def render_or_raw(result)
    if (menu_options = @global_options.delete(:menu))
      filters = @global_options.delete(:filters)
      result = ::Hirb::Helpers::AutoTable.render(result, @global_options.merge(:return_rows=>true))
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
      @is_hash = items[0].is_a?(Hash)
      @fields = @global_options[:fields] ? @global_options[:fields] :
        @global_options[:change_fields] ? @global_options[:change_fields] :
        items[0].is_a?(Hash) ? items[0].keys : [:to_s]
      @default_field = @options[:default_field] ? unalias_field(@options[:default_field]) : @fields[0]
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
      ::Boson.invoke(:menu, @items, :return_input=>true, :fields=>@fields, :prompt=>"Default field: #{@default_field}\nChoose: ")
    end

    def unalias_field(field)
      @fields.sort_by {|e| e.to_s }.find {|e| e.to_s[/^#{field}/] } || field
    end

    def parse_and_invoke(input)
      cmd, *args = parse_input(input)
      @options[:once] ? invoke(cmd, args) : args.each {|e| invoke(cmd, [e]) }
    end

    def invoke(cmd, args)
      if @options[:pretend]
        puts "#{cmd} #{args.inspect}"
      else
        output = ::Boson.full_invoke cmd, args
        unless ::Boson::View.silent_object?(output)
          opts = output.is_a?(String) ? {:method=>'puts'} : {:inspect=>!output.is_a?(Array) }
          ::Boson::View.render(output, opts)
        end
      end
    end

    def get_template(args)
      template = args.join(' ')
      if template.empty?
        template_args = [@default_field]
        template = "%s"
      else
        template_args = []
        template.gsub!(/%s|:\w+/) {|e|
          template_args << (e == '%s' ? @default_field : unalias_field(e[/\w+/]))
          "%s"
        }
      end
      [template, template_args]
    end

    def map_item(obj, field)
      @is_hash ? obj[field] : obj.send(field)
    end

    def parse_input(input)
      @options[:template] ? parse_template(input) : parse_default(input)
    end

    def parse_template(input)
        num, cmd, *args = Shellwords.shellwords(input)
        chosen = ::Hirb::Util.choose_from_array(@items, num)
        template, template_args = get_template(args)
        cmd_args = chosen.map {|e| sprintf(template, *template_args.map {|field| map_item(e, field) }) }
        [cmd] + cmd_args
    end

    def parse_default(input)
      Shellwords.shellwords(input).map {|word|
        if word[/^(\d(?:[^:]+)?)(?::)?(\S+)?/]
          field = $2 ? unalias_field($2) : @default_field
          ::Hirb::Util.choose_from_array(@items, $1).map {|e| map_item(e, field) }
        else
          word
        end
      }.flatten
    end
  end
end

module Menu
end