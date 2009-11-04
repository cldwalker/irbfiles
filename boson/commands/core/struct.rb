module StructLib
  # Creates an object from a Struct-defined class given a hash of attributes
  def open_struct(hash)
    Struct.new(*hash.keys.sort).new(*hash.values_at(*hash.keys.sort))
  end

  # from http://blog.rubybestpractices.com/posts/rklemme/017-Struct.html
  # Makes a Struct class comparable
  def self.comparable  
    define_method :<=> do |o|  
      members.each do |m|  
        c = self[m] <=> o[m]  
        return c unless c == 0  
      end  
      0  
    end  
    include Comparable  
  end  
end