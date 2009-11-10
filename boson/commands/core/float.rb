module FloatLib
  # Round to a number of decimal places
  def round_to(float, place)
    #(float * 10 ** place).round.to_f / 10 ** place
    sprintf("%.#{place}f", float).to_f
  end
end