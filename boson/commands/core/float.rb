module FloatLib
  # Round to a number of decimal places
  def round_to(float, place)
    sprintf("%.#{place}f", float).to_f
  end
end