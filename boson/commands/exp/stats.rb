module Stats
  # Calculates total for all numeric keys in an array of hashes
  def totals(enumerable)
    Stats.calculate(enumerable, :total)
  end

  # Calculates average for all numeric keys in an array of hashes
  def average(enumerable)
    Stats.calculate(enumerable, :average)
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
      float = enumerable.inject(0) {|t,e| t + e[key]} / enumerable.size.to_f
      sprintf("%.2f", float).to_f
    end

    def calculate_total(enumerable, key)
      enumerable.inject(0) {|t,e| t + e[key] }
    end
  end
end