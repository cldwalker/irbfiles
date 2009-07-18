# from http://gist.github.com/148765
#puts Countdown.ask("Do you like pie?", 30.0, false)
require 'termios'

module Countdown
  extend self
  def ask(question, seconds, default)
    with_unbuffered_input($stdin) do
      countdown_from(seconds) do |seconds_left|
        write_then_erase_prompt(question, seconds_left) do
          wait_for_input($stdin, seconds_left % 1) do
            case char = $stdin.getc
            when ?y, ?Y then return true
            when ?n, ?N then return false
            else # NOOP
            end
          end
        end
      end
    end
    return default
  ensure
    $stdout.puts
  end

  def with_unbuffered_input(input = $stdin)
    old_attributes = Termios.tcgetattr(input)
    new_attributes = old_attributes.dup
    new_attributes.lflag &= ~Termios::ECHO
    new_attributes.lflag &= ~Termios::ICANON
    Termios::tcsetattr(input, Termios::TCSANOW, new_attributes)

    yield
  ensure
    Termios::tcsetattr(input, Termios::TCSANOW, old_attributes)
  end # with_unbuffered_input

  def countdown_from(seconds_left)
    start_time = Time.now
    end_time = start_time + seconds_left
    begin
      yield(seconds_left)
      seconds_left = end_time - Time.now
    end while seconds_left > 0.0
  end # countdown_from

  def write_then_erase_prompt(question, seconds_left)
    prompt_format = "#{question} (y/n) (%2d)"
    prompt = prompt_format % seconds_left.to_i
    prompt_length = prompt.length
    $stdout.write(prompt)
    $stdout.flush

    yield

    $stdout.write("\b" * prompt_length)
    $stdout.flush
  end # write_then_erase_prompt

  def wait_for_input(input, timeout)
    # Wait until input is available
    if select([input], [], [], timeout)
      yield
    end
  end # wait_for_input
end
