# consider features from http://github.com/JosephPecoraro/rr/tree/master
module Gsub
  def self.config
    {:force=>true}
  end

  # Search and replace given globbed files
  def gsub(search, replace, files, for_real=false)
    string = for_real ? "ruby -pi" : "ruby -p"
    files = "#{files}/**/*.rb" if File.directory?(files)
    string += %[ -e "gsub('#{search}','#{replace}')" #{Dir[files].join(' ')}]
    system(string)
  end
end