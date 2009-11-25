module Dbm
  def self.config; {:namespace=>true}; end
  def self.included(mod)
    require 'dbm'
  end

  def write(hash, file='blah.dbm')
    DBM.open(file) do |e|
      hash.each do |k,v|
        e[k] = v
      end
    end
  end

  def read(file='blah.dbm')
    DBM.open(file).to_hash
  end
end
