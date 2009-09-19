module FindLib
  def self.included(mod)
    require 'file/find' #gem install file-find
  end

  # @options :maxdepth=>:numeric, :path=>:array, :return_array=>:boolean, :prune=>:string
  # A *nix like find that can return an array of found files
  def find(pattern, options={})
    return_array = options.delete(:return_array)
    rule = File::Find.new(options.merge(:name=>pattern))
    files = []
    rule.find {|f| puts f; files << f }
    files if return_array
  end
end
