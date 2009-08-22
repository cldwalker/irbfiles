module Pstore
  def self.included(mod)
    require 'pstore'
  end

  def db_init(yaml=false)
    if yaml
      require 'yaml'
      require 'yaml/store'
      @db = YAML::Store.new(File.join(Boson.dir, 'main.pstore.yml'))
    else
      @db = PStore.new(File.join(Boson.dir, 'main.pstore'))
    end
  end

  def db
    @db || db_init
  end

  def db_keys
    @db.transaction { @db.roots }
  end

  def db_hash
    keys = db_keys
    @db.transaction { keys.inject({}) {|h,e| h[e] = @db[e]; h } }
  end
end
  