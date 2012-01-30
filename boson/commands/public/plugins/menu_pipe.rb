# This menu class builds on hirb's menus to bring 2D action menus to boson commands
# at the flick of a switch. For example to invoke `boson commands` with a menu: `boson commands -m`.
# This library should be configured as a default library in order for the menu option to show up.
#
# This class adds two important features to menus: options at the menu prompt and action templates.
# Pull up option help at a menu prompt with `-h` or `--help` to see what each option does.
# Templates are a convenient way of creating a string involving multiple cell values.
class ::TwoDMenu < ::Hirb::Menu
  OPTIONS = {:default_field=>{:type=>:string, :desc=>"Default field for 2d menu"},
    :pretend=>{:type=>:boolean, :desc=>"Prints commands that would be executed"},
    :multi_action=>{:type=>:boolean, :desc=>"Menu choices are executed one at a time by a command instead of all at once."},
    :help=>{:type=>:boolean, :desc=>'Prints menu options help'},
    :command=>{:type=>:string, :desc=>'Command to apply as menu action'},
    :splat=>{:type=>:boolean, :desc=>'Flats all arguments'},
    :object=>{:type=>:boolean, :desc=>'Menu choices pick out actual objects from rows instead of from individual cells'},
    :template=>{:type=>:string, :desc=>'Template to apply to each choice'}
  }

  def self.option_parser
    @option_parser ||= ::Boson::OptionParser.new OPTIONS
  end

  # Takes the following options in addition to Hirb::Menu's options:
  # * :pretend: Boolean to pretend to execute commands by printing them.
  # * :splat: Boolean to flatten all arguments. Necessary for commands that have splat arguments.
  # * :object: Boolean to make menu a 1d menu. This means menu choices return objects associated with rows instead of
  #   individual cells
  # * template: String to apply to menu choices instead of using command arguments
  def initialize(options={})
    options = (options[:config] || {}).merge(options[:global_options] || {})
    raise Error, "Can't handle commands with :change_fields option" if options[:change_fields]
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

  def pre_prompt
    @options[:template] ? super + "Default template: #{@options[:template]}\n" : super
  end

  def handle_template(items)
    if new_options[:template] || (@options[:template] && @new_args == [CHOSEN_ARG] && (command == @options[:command]))
      items = ::Hirb::Util.choose_from_array(@output, @args[-1].to_s)
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
    ::Boson::Index.read
    # Unaliasing cmd so autoload_command can find it
    cmd = ::Boson::Util.underscore_search(cmd, Boson::Index.all_main_methods, true) || cmd
    # loading because Index doesn't have command's config
    ::Boson::BareRunner.autoload_command(cmd) unless ::Boson.can_invoke?(cmd) || ::Boson::Command.find(cmd)

    options = {}
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
      :desc=>'Displays a menu that can execute commands on any cell',
      :no_render=>true, :env=>true, :solo=>true, :pipe=>:two_d_menu, :filter=>true
    }
  end

  # Runs a 2D action menu
  def two_d_menu(output, menu_opts)
    ::TwoDMenu.render(output, menu_opts)
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
