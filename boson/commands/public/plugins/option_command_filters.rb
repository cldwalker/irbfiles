class ::Boson::OptionCommand
  module Filters; end
  include Filters
  alias_method :_parse, :parse

  def self.extract_argument(arg_name)
    arg_name.gsub(/^\*(.*?)s?$/, '\1')
  end

  def parse(args)
    global_options, parsed_options, args = _parse(args)
    filter_options(parsed_options) if parsed_options
    filter_args(args)
    [global_options, parsed_options, args]
  end

  def filter_args(args)
    return unless @command.args #not all commands have args detected
    args.each_with_index do |arg,i|
      break unless @command.args[i] && (arg_name = @command.args[i][0])
      arg_name = self.class.extract_argument(arg_name)
      if respond_to?("#{arg_name}_argument")
        args[i] = send("#{arg_name}_argument", arg)
        puts "argument: #{arg.inspect} -> #{args[i].inspect}" if Boson::Runner.verbose?
      end
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
end