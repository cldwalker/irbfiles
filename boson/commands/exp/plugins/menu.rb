class ::TwoDMenu < ::Hirb::Menu
  OPTIONS = {:default_field=>:string, :pretend=>:boolean, :multi_action=>:boolean, :help=>:boolean,
    :command=>:string, :splat=>:boolean, :object=>:boolean, :template=>:string}

  def self.option_parser
    @option_parser ||= ::Boson::OptionParser.new OPTIONS
  end

  def initialize(options={})
    options = (options[:config] || {}).merge(options[:global_options] || {})
    super options.merge(:two_d=>true, :readline=>true, :action=>true)
  end

  def split_input_args(input)
    args = Shellwords.shellwords(input)
    @new_options = self.class.option_parser.parse(args, :opts_before_args=>true)
    @options = @options.merge @new_options
    args
  end

  def return_cell_values?
    @options[:two_d] && !@options[:object]
  end

  def execute_action(items)
    if @options[:help]
      self.class.option_parser.print_usage_table
    else
      @options = command_option_defaults(command).merge(@options)
      super(handle_template(items))
      p @options if @options[:pretend]
    end
    nil
  end

  # in case :ask=>false
  def new_options
    @new_options || {}
  end

  def handle_template(items)
    if new_options[:template] || (@options[:template] && @new_args == [CHOSEN_ARG] && (command == @options[:command]))
      items = ::Hirb::Util.choose_from_array(@output, @args[-1])
      items.map! {|e| apply_template(e) }
    else
      items
    end
  end

  def apply_template(item)
    @options[:template].gsub(/:\w+/) {|e|
      field = unalias_field(e[/\w+/])
      @output[0].is_a?(Hash) ? item[field] : item.send(field)
    }
  end

  def command_option_defaults(cmd)
    options = {}
    ::Boson::Runner.autoload_command(cmd) unless ::Boson.can_invoke?(cmd) || ::Boson::Command.find(cmd)
    if (cmd_obj = ::Boson::Command.find(cmd))
      options[:splat] = true if cmd_obj.has_splat_args?
      options[:multi_action] = true if !cmd_obj.has_splat_args? && cmd_obj.args && cmd_obj.arg_size <= 2
      options.merge! cmd_obj.config[:menu_action] || {}
    end
    options
  end

  def invoke(cmd, args)
    if @options[:pretend]
      puts "#{cmd} #{@options[:splat] ? '*' : ''}#{args.inspect}"
    else
      cmd = cmd.to_s
      output = @options[:splat] ? (::Boson.full_invoke cmd, args.flatten) : ::Boson.full_invoke(cmd, args)
      unless ::Boson::View.silent_object?(output)
        opts = output.is_a?(String) ? {:method=>'puts'} : {:inspect=>!output.is_a?(Array) }
        ::Boson::View.render(output, opts)
      end
    end
  end
end

module MenuLib
  def self.after_included
    require 'shellwords'

    ::Boson::Pipe.add_pipes :menu=>{ :type=>:boolean, :alias=>'m',
      :no_render=>true, :env=>true, :solo=>true, :pipe=>:two_d_menu, :filter=>true
    }
  end

  # Runs a 2D action menu
  def two_d_menu(output, menu_opts)
    ::TwoDMenu.render(output, menu_opts)
  end

  # @render_options :fields=>[:name, :homepage]
  def gemspecs
    ::Gem.source_index.gems.values[0,10]
  end
end

__END__
# to add in some time
  if @options[:shell]
    while input != 'q'
      parse_and_invoke input
      input = get_input
    end
  else
    parse_and_invoke input
  end
end