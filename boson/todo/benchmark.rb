# Awesome benchmarking function
# Source: http://ozmm.org/posts/time_in_irb.html
def time(times=1)
  require "benchmark"
  ret = nil
  Benchmark.bm { |x| x.report { times.times { ret = yield } } }
  ret
end

# next two from http://pastie.org/private/lx4szvl91miofmyjl46va
def bench(n=100, runs=10, &b)
  n = n.to_i
  t = []
  runs.times do
    a = Time.now
    n.times(&b)
    t << (Time.now-a)*1000/n
  end
  mean   = t.inject { |a,b| a+b }.quo(t.size)
  stddev = t.map { |a| (a-mean)**2 }.inject { |a,b| a+b }.quo(t.size)**0.5
  [mean, stddev]
end

# tiny bench method with nice printing
 def pbench(n=1, runs=5, &b)
   m, s = *bench(n,runs,&b)
   p    = (100.0*s)/m
   printf "ø %fms (%.1f%%)\n", m, p
 end

#from http://github.com/mislav/dotfiles/tree/master/irbrc
if defined? Benchmark
  class Benchmark::ReportProxy
    def initialize(bm, iterations)
      @bm = bm
      @iterations = iterations
      @queue = []
    end
    
    def method_missing(method, *args, &block)
      args.unshift(method.to_s + ':')
      @bm.report(*args) do
        @iterations.times { block.call }
      end
    end
  end
 
  def compare(times = 1, label_width = 12)
    Benchmark.bm(label_width) do |x|
      yield Benchmark::ReportProxy.new(x, times)
    end
  end
end

#http://blog.evanweaver.com/articles/2006/12/13/benchmark/
