#from http://fukamachi.org/wp/2008/12/31/dead-simple-reload-for-ruby/
module AutoReload
 
  @@required_mod_times = {}
 
  def reload!
    diffs = AutoReload.differences # we can only call it once per reload, obviously
    if diffs.size > 0
      diffs.each {|f| Kernel.load(f)}
      puts "reloaded #{diffs.size} file(s): #{diffs.join(', ')}"
    else
      puts "nothing to reload"
    end
  end
 
  def self.update_modtimes
    $".each do |f|
      @@required_mod_times[f] = File.mtime(f) if File.exists?(f)
    end
  end
 
  def self.differences
    oldlist = @@required_mod_times.clone
    AutoReload.update_modtimes
    newlist = @@required_mod_times.clone
    oldlist.delete_if {|key, value| newlist[key] == value }
    oldlist.keys.uniq
  end
 
end
