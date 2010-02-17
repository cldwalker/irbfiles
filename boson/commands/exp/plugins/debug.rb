module ::Boson::Scientist
  alias_method :_call_original_command, :call_original_command
  # benchmark version
  # def call_original_command(args, &block)
  #   require 'benchmark'
  #   output = nil
  #   bench = Benchmark.measure do
  #     output = _call_original_command(args, &block)
  #   end
  #   puts "  #{name} --> #{bench}"
  #   output
  # end

  # debug version
  def call_original_command(args, &block)
    $DEBUG = true  # set_trace_func lambda {|*e| p e }
      output = _call_original_command(args, &block)
    $DEBUG = false # set_trace_func nil
    output
  end
end