module ::Boson::Scientist
  alias_method :_render_or_raw, :render_or_raw
  def render_or_raw(result)
    if (menu_options = @global_options.delete(:menu))
      menu_options = (@command.config[:menu] || {}).merge menu_options
      Menu.run(result, menu_options, @global_options)
      nil
    else
      # @global_options[:render] = true
      _render_or_raw(result)
    end
  end

  class Menu
    require 'shellwords'
    CHOSEN_REGEXP = /^(\d([^:]+)?)(?::)?(\S+)?/
    OPTIONS = {:default_field=>:string, :shell=>:boolean, :pretend=>:boolean, :once=>:boolean, :help=>:boolean,
      :multi=>:boolean, :object=>:boolean, :command=>:string, :args=>:string, :splat=>:boolean}

    def self.run(items, options, global_options)
      filters = global_options.delete(:filters)
      options.merge! :filters=>filters, :items=>items
      new_items = ::Hirb::Helpers::AutoTable.render(items, global_options.merge(:return_rows=>true))
      new(new_items, options, global_options).run
    end

    def self.option_parser
      @option_parser ||= ::Boson::OptionParser.new OPTIONS
    end

    def initialize(items, options, global_options)
      @items, @default_options, @global_options = items, options, global_options
      @options = @default_options.dup
      @is_hash = items[0].is_a?(Hash)
      @fields = @global_options[:fields] ? @global_options[:fields] :
        @global_options[:change_fields] ? @global_options[:change_fields] :
        items[0].is_a?(Hash) ? items[0].keys : [:to_s]
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
      prompt = @options[:object] ? "Choose objects: " : "Default field: #{default_field}\nChoose rows: "
      ::Boson.invoke(:menu, @items, :return_input=>true, :fields=>@fields, :prompt=>prompt, :readline=>true)
    end

    def parse_and_invoke(input)
      cmd, *args = parse_input(input)
      if @options[:help]
        self.class.option_parser.print_usage_table
      else
        @options[:once] ? invoke(cmd, args) : args.flatten.each {|e| invoke(cmd, [e]) }
      end
    end

    def parse_input(input)
      args = Shellwords.shellwords(input)
      @options = @default_options.merge self.class.option_parser.parse(args, :opts_before_args=>true)
      return if @options[:help]
      @options[:multi] ? parse_multi(args) : parse_template(args)
    end

    def invoke(cmd, args)
      @options[:splat] = true if ::Boson::Index.read && (cmd_obj = ::Boson::Index.find_command(cmd)) &&
        cmd_obj.has_splat_args?
      if @options[:pretend]
        puts "#{cmd} #{@options[:splat] ? '*' : ''}#{args.inspect}"
      else
        output = @options[:splat] ? (::Boson.full_invoke cmd, args.flatten) : ::Boson.full_invoke(cmd, args)
        unless ::Boson::View.silent_object?(output)
          opts = output.is_a?(String) ? {:method=>'puts'} : {:inspect=>!output.is_a?(Array) }
          ::Boson::View.render(output, opts)
        end
      end
    end

    def process_template(args)
      return args if @options[:object]
      template = @options[:args] && args.size <= 1 ? @options[:args] : args.join(' ')
      if template.empty?
        template_args = [default_field]
        template = "%s"
      else
        template_args = []
        template.gsub!(/%s|:\w+/) {|e|
          template_args << (e == '%s' ? default_field : unalias_field(e[/\w+/]))
          "%s"
        }
      end
      Array(@chosen).map {|e| sprintf(template, *template_args.map {|field| map_item(e, field) }) }
    end

    def parse_template(args)
      args = args.map do |word|
        if word[CHOSEN_REGEXP] && !@seen
          field = $3 ? ":#{unalias_field($3)}" : '%s'
          @chosen = ::Hirb::Util.choose_from_array(items, $1)
          @seen = true
          @options[:object] ? @chosen : field
        else
          word
        end
      end
      cmd = args.size == 1 ? @options[:command] : args.shift
      raise "No command given" unless cmd
      [cmd] + process_template(args)
    end

    # doesn't work w/ :object
    def parse_multi(args)
      args.map {|word|
        if word[CHOSEN_REGEXP]
          field = $3 ? unalias_field($3) : default_field
          ::Hirb::Util.choose_from_array(items, $1).map {|e| map_item(e, field) }
        else
          word
        end
      }.flatten
    end

    def items
      @options[:object] ? @default_options[:items] : @items
    end

    def default_field
      @options[:default_field] ? unalias_field(@options[:default_field]) : @fields[0]
    end

    def map_item(obj, field)
      @is_hash ? obj[field] : obj.send(field)
    end

    def unalias_field(field)
      @fields.sort_by {|e| e.to_s }.find {|e| e.to_s[/^#{field}/] } || field
    end
  end
end

::Boson::OptionCommand::PIPE_OPTIONS[:menu] = { :bool_default=>{},
  :alias=>['m'], :type=>:hash, :keys=>::Boson::Scientist::Menu::OPTIONS.keys
}