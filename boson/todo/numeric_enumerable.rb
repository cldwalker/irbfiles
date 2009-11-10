# from nairda-ruby-util gem
module Enumerable
  # Calculates sum of the collection.
  def sum
    inject(nil) { |sum, x| sum ? sum + x : x }
  end

  # Calculates inversed sum of the collection.
  def inversed_sum
    1.0 / sum
  end

  # Calculates reverse sum of the collection.
  def reverse_sum
    sum.to_i > 0 ? inject(nil) { |sum, x| sum ? sum + 1.0 / x : 1.0 / x } : 0
  end

  # Calculates square root sum of the collection.
  def square_root_sum
    inject(nil) { |sum, x| sum ? sum + x ** 2 : x ** 2 }
  end

  # Multiplicates all elements of the collection.
  def product
    inject(nil) { |mul, x| mul ? mul * x : x }
  end

  alias_method :multiply, :product

  # Calculates arithmectic mean of all elements in the collection.
  def arithmetic_mean
    size > 0 ? sum.to_f / size : 0
  end

  alias_method :average, :arithmetic_mean

  # Calculates geometric mean of all elements in the collection.
  def geometric_mean
    size > 0 ? Math.root(product, size) : 0
  end

  # Calculates harmonic mean of all elements in the collection.
  def harmonic_mean
    size > 0 ? size / reverse_sum : 0
  end

  # Calculates root mean square of all elements in the collection.
  def root_mean_square
    size > 0 ? Math.sqrt(square_root_sum / size) : 0
  end
end
