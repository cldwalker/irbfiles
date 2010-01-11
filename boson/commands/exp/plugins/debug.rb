module ::Boson::Scientist
  alias_method :_call_original_command, :call_original_command
  def call_original_command(args, &block)
    $DEBUG = true  # set_trace_func lambda {|*e| p e }
    output = _call_original_command(args, &block)
    $DEBUG = false # set_trace_func nil
    output
  end
end