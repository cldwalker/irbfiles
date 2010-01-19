class ::Boson::OptionCommand
  module Filters; end
  include Filters
  alias_method :_parse, :parse

  def parse(args)
    global_options, parsed_options, args = _parse(args)
    filter_options(parsed_options) if parsed_options
    filter_args(args)
    [global_options, parsed_options, args]
  end

  def filter_args(args)
    return unless @command.args #not all commands have args detected
    if @command.has_splat_args?
      arg_name = (@command.args[0][0] || '').sub(/^\*/, '')
      call_plural_arg_filter(args, arg_name)
    else
      args.each_with_index do |arg,i|
        break unless @command.args[i] && (arg_name = @command.args[i][0])
        arg_name[/s$/] ? call_plural_arg_filter(arg, arg_name) : call_arg_filter(args, i, arg_name, arg)
      end
    end
  end

  def call_plural_arg_filter(args, arg_name)
    if respond_to?("#{arg_name}_argument")
      new_args = send("#{arg_name}_argument", args)
      puts "argument: #{args.inspect} -> #{new_args.inspect}" if Boson::Runner.verbose?
      args.replace new_args
    else
      args.each_with_index {|arg, i|
        call_arg_filter(args, i, arg_name.gsub(/s$/,''), arg)
      }
    end
  end

  def call_arg_filter(args, i, arg_name, arg)
    if respond_to?("#{arg_name}_argument")
      args[i] = send("#{arg_name}_argument", arg)
      puts "argument: #{arg.inspect} -> #{args[i].inspect}" if Boson::Runner.verbose?
    end
  end

  def filter_options(options)
    options.each do |name,value|
      if respond_to?("#{name}_opt")
        options[name] = send("#{name}_opt", value)
        puts "option: #{value.inspect} -> #{options[name].inspect}" if Boson::Runner.verbose?
      end
    end
  end
end

# This plugin filters arguments and options passed to option commands (Boson::OptionCommand).
# Arguments and options are intercepted by name and filtered by corresponding methods defined in
# the module Boson::OptionCommand::Filters. For example, an argument or option named 'klass' is filtered by
# a method 'klass_argument' or 'klass_opt'.
module OptionCommandFilters
  # @options :options=>:boolean
  # @render_options {}
  def filters(options={})
    str = options[:options] ? '_opt' : '_argument'
    ::Boson::OptionCommand.instance_methods.grep(/#{str}$/).map {|e| e.gsub(str, '') }.sort
  end

  # @render_options :change_fields=>['arguments', 'commands'],
  #  :filters=>{:default=>{'commands'=>:inspect}}
  # @options :count=>:boolean, :transform=>:boolean
  # Lists arguments from all known commands. Depends on option_command_filters plugin.
  def arguments(options={})
    Boson::Index.read
    hash = Boson::Index.commands.inject({}) {|t,com|
      (com.args || []).each {|arg|
        arg_name = options[:transform] ? arg[0].to_s.gsub(/^\*|s$/, '') : arg[0]
        (t[arg_name] ||= []) << com.name
      }
      t
    }
  end
end