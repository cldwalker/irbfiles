module Browser
  # non-mac users should use launchy here
  def browser(*urls)
    system(*(['open'] + urls))
  end
end