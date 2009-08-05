#from README of irb_callbacks gem
require 'irb_callbacks'
require 'benchmark'

# This little snippet will time each command run via the console.

module IRB
  def self.around_eval(&block)
    @timing = Benchmark.realtime do
      block.call
    end
  end

  def self.after_output
    puts "=> #{'%.3f' % @timing} seconds"
  end
end

