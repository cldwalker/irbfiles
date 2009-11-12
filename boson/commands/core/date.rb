module DateLib
  def day_name(date)
    Date::DAYNAMES[date.cwday]
  end
end