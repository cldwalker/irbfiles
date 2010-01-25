module Histogram
  def self.included(mod)
    require 'aggregate'
  end

  # irb> stats(100, 0, 10, 1) { sleep(rand / 100) }
  # mean:   5.99ms
  # min:    1.49ms
  # max:    9.28ms
  # stddev: 2.54ms
  # value |------------------------------------------------------------------| count
  #     0 |@@                                                                |     2
  #     1 |@@@@@@@@@@@@@                                                     |    13
  #     2 |@@@@@@@@@@                                                        |    10
  #     3 |@@@@@@@@@@                                                        |    10
  #     4 |@@@@@@@@@@@@                                                      |    12
  #     5 |@@@@@@@@@@@                                                       |    11
  #     6 |@@@@@@@@@@@@@                                                     |    13
  #     7 |@@@@@                                                             |     5
  #     8 |@@@@@@@@@@@@                                                      |    12
  #     9 |@@@@@@@@                                                          |     8
  # Total |------------------------------------------------------------------|    96

  # originally from http://gist.github.com/187669
  # @desc Run the given block +num+ times and then print out the mean, min,
  # max, std_dev, and histogram of the run duration.
  def run_stats(num,low,high,width)
    records = Aggregate.new(low, high, width)
    num.times do
      t0 = Time.now
      yield
      records << (Time.now - t0) * 1000
    end

    puts "mean:   %1.2fms" % records.mean
    puts "min:    %1.2fms" % records.min
    puts "max:    %1.2fms" % records.max
    puts "stddev: %1.2fms" % records.std_dev

    puts records.to_s
  end

  # @options :max=>:numeric, :width=>:numeric, :min=>0, :verbose=>:boolean
  # @config :alias=>'hs'
  # Auto histogram divided into ten buckets by default
  def histostat(arr, options={})
    max = options[:max] || begin
      tens_place = (-3..7).find {|e| 10 ** e > arr.max }
      (1..10).find {|e| (10 ** (tens_place - 1) * e) > arr.max } * 10 ** (tens_place - 1)
    end
    min = options[:min]
    width = options[:width] || begin
      temp = ((max - min) / (10.0)).round
      temp.zero? ? 1 : temp
    end

    puts "min: %s, max: %s, width: %s" % [min, max, width] if options[:verbose]
    # kept throwing errors b/c of range.modulo(width) != 0
    # agg = Aggregate.new(arr.min, arr.max, (arr.max - arr.min) / 10.0)
    agg = Aggregate.new(min, max, width)
    arr.each {|e| agg << e }
    puts agg.to_s
  end
end