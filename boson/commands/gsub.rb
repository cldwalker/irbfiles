module Gsub
  def gsub(search, replace, files, for_real=false)
    string = for_real ? "ruby -pi" : "ruby -p"
    string += %[ -e "gsub('#{search}','#{replace}')" #{Dir[files].join(' ')}]
    system(string)
  end
end