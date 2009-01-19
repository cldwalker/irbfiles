#from http://dotfiles.org/~brendano/.irbrc
def loadmar(filename)  open(filename) { |f| Marshal.load f}  end
def savemar(o, filename)
    open(filename,'w') { |f| Marshal.dump o, f}
      filename
end

# yaml and marshal i/o

def loadyaml(filename)  YAML.load_file(filename)  end
def saveyaml(o, filename)
  open(filename,'w') { |f| YAML.dump o, f }
  filename
end
def load_yaml_docs(stream)
  x = []
  YAML.load_documents(stream) {|d| x << d }
  x
end
def save_yaml_docs(items, stream)
  items.each{|x| stream << x.to_yaml }
end

# Why's aorta method to edit an object in YAML, awesome!
# Source: http://rubyforge.org/snippet/detail.php?type=snippet&id=22
def aorta( obj )
  tempfile = File.join('/tmp',"yobj_#{ Time.now.to_i }")
  File.open( tempfile, 'w' ) { |f| f << obj.to_yaml }
  system( "#{ ENV['EDITOR'] || 'vi' } #{ tempfile }" )
  return obj unless File.exists?( tempfile )
  content = YAML::load( File.open( tempfile ) )
  File.delete( tempfile )
  content
end
def aorta!(obj)
  obj = aorta(obj)
end
