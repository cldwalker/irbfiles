# Silence and/or captures output.
module Silencer
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  def silence_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def silence_stderr(&block)
    original_stdout = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = original_stdout
    end
    fake.string
  end
end