require 'shellwords'
class ::TwoDMenu < ::Hirb::Menu
  OPTIONS = {:default_field=>:string, :pretend=>:boolean, :multiple_execute=>:boolean, :help=>:boolean,
    [:default_command, :c]=>:string, :splat=>:boolean, :object=>:boolean, :template=>:string}

  def self.option_parser
    @option_parser ||= ::Boson::OptionParser.new OPTIONS
  end

  def initialize(options={})
    options = (options[:config] || {}).merge(options[:global_options] || {})
    super options.merge(:two_d=>true, :readline=>true, :execute=>true)
  end

  def split_input_args(input)
    args = Shellwords.shellwords(input)
    @options = @options.merge self.class.option_parser.parse(args, :opts_before_args=>true)
    args
  end

  def return_cell_values?
    @options[:two_d] && !@options[:object]
  end

  def execute(items)
    @options[:help] ? self.class.option_parser.print_usage_table :
      super(handle_template(items))
    nil
  end

  def handle_template(items)
    if @options[:template] && command && @new_args == [CHOSEN_ARG]
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
end

module MenuLib
  def self.after_included
    ::Boson::Pipe.add_pipes :menu=>{ :type=>:boolean, :alias=>'m',
      :no_render=>true, :env=>true, :solo=>true, :pipe=>:two_d_menu, :filter=>true
    }
  end

  def two_d_menu(output, menu_opts)
    # ::Hirb::Menu.render(output, menu_opts.merge(:execute=>true, :two_d=>true))
    ::TwoDMenu.render(output, menu_opts)
  end

  # @render_options :fields=>[:name, :homepage]
  def gemspecs
    ::Gem.source_index.gems.values[0,10]
  end

  # Runs an awesome menu system on top of hirb's tables
  def run_menu(result, menu_opt, env)
    ::Menu.run(result, menu_opt, env)
    nil
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

  prompt = @options[:object] ? "Choose objects: " :
    @options[:args] ? "Default args: #{@options[:args]}\nChoose rows: " :
    "Default field: #{default_field}\nChoose rows: "
