class ::Boson::OptionCommand
  module Filters; extend self end
  include Filters
  alias_method :_parse, :parse

  def parse(args)
    global_options, parsed_options, args = _parse(args)
    filter_options(parsed_options) if parsed_options
    filtered_args = filter_args(args)
    [global_options, parsed_options, filtered_args]
  end

  def filter_args(args)
    return args unless @command.args #not all commands have args detected
    new_args = []
    args.each_with_index do |arg,i|
      break unless @command.args[i] && (arg_name = @command.args[i][0])

      if arg_name[/^\*/]
        new_args += call_plural_arg_filter(args[i..-1], arg_name.sub(/^\*/,''))
        break
      else
        new_arg = arg_name[/s$/] ? call_plural_arg_filter(arg, arg_name) :
          respond_to?("#{arg_name}_argument") ? call_arg_filter(arg_name, arg) : arg
        new_args << new_arg
      end
    end
    new_args
  end

  def call_plural_arg_filter(args, arg_name)
    if respond_to?("#{arg_name}_argument")
      call_arg_filter(arg_name, args)
    elsif arg_name.gsub!(/s$/,'') && respond_to?("#{arg_name}_argument") && args.is_a?(Array)
      args.map {|e| call_arg_filter(arg_name, e) }
    else
      args
    end
  end

  def call_arg_filter(arg_name, arg)
    new_arg = send("#{arg_name}_argument", arg)
    puts "argument: #{arg.inspect} -> #{new_arg.inspect}" if Boson.verbose
    new_arg
  end

  def filter_options(options)
    options.each do |name,value|
      if respond_to?("#{name}_option")
        options[name] = send("#{name}_option", value)
        puts "option: #{value.inspect} -> #{options[name].inspect}" if Boson.verbose
      end
    end
  end
end

# This plugin filters arguments and options passed to option commands (Boson::OptionCommand).
# Arguments and options are intercepted by name and filtered by corresponding methods defined in
# the module Boson::OptionCommand::Filters. For example, an argument or option named 'klass' is filtered by
# a method 'klass_argument' or 'klass_option'.
module OptionCommandFilters
  # @options :options=>:boolean
  # @render_options {}
  # Lists filters
  def filters(options={})
    filter_type = options[:options] ? '_option' : '_argument'
    ::Boson::OptionCommand.instance_methods.grep(/#{filter_type}$/).map {|e| e.gsub(filter_type, '') }.sort
  end

  # @options :options=>:boolean
  # Calls filters
  def call_filter(filter, filter_arg, options={})
    filter_type = options[:options] ? '_option' : '_argument'
    ::Boson::OptionCommand::Filters.send "#{filter}#{filter_type}", filter_arg
  end

  # @render_options :change_fields=>['arguments', 'commands'],
  # @options :current_commands=>:boolean, :transform=>:boolean
  # Lists arguments from all known commands. Depends on option_command_filters plugin.
  def arguments(options={})
    commands = options[:current_commands] ? Boson.commands.select {|e| e.option_command? } :
      Boson::Index.read && Boson::Index.commands
    commands.inject({}) {|t,com|
      (com.args || []).each {|arg|
        arg_name = options[:transform] ? arg[0].to_s.gsub(/^\*|s$/, '') : arg[0]
        (t[arg_name] ||= []) << com.name
      }
      t
    }
  end
end
