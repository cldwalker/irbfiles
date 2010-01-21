module Stats
  # Calculates total for all numeric keys in an array of hashes
  def totals(enumerable)
    Stats.calculate(enumerable, :total)
  end

  # Calculates average for all numeric keys in an array of hashes
  def average(enumerable)
    Stats.calculate(enumerable, :average)
  end

  # Calculates standard deviation for all numeric keys in aoh
  def stddev(enumerable)
    Stats.calculate(enumerable, :stddev)
  end

  # Calculates median for all numeric keys in aoh
  def median(enumerable)
    Stats.calculate(enumerable, :median)
  end

  class <<self
    def calculate(enumerable, stat)
      return enumerable if enumerable.size.zero?
      numeric_keys = enumerable[0].select {|k,v| v.is_a?(Numeric) }.map {|e| e[0] }
      totals = enumerable[0].keys.inject({}) {|t,key|
        t[key] = numeric_keys.include?(key) ? 
          send("calculate_#{stat}", enumerable, key) : ''
        t
      }
      enumerable << enumerable[0].keys.inject({}) {|t,e| t[e] = ''; t} << totals
    end

    def calculate_average(enumerable, key)
      round exact_average(enumerable, key)
    end

    def round(num)
      sprintf("%.2f", num).to_f
    end

    def calculate_stddev(enumerable, key)
      avg = exact_average(enumerable, key)
      round Math.sqrt(enumerable.inject(0) {|t,e| t + (e[key] - avg) ** 2 } / enumerable.size.to_f )
    end

    def calculate_median(enumerable, key)
      enumerable.map {|e| e[key] }.sort[enumerable.size / 2]
    end

    def exact_average(enumerable, key)
      enumerable.inject(0) {|t,e| t + e[key]} / enumerable.size.to_f
    end

    def calculate_total(enumerable, key)
      enumerable.inject(0) {|t,e| t + e[key] }
    end
  end
end