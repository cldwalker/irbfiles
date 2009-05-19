module Iam::Libraries::Pstore
  def self.init
    require 'pstore'
  end

  def pdb
    @pdb ||= PStore.new(File.join(Iam.base_dir, 'main.pstore'))
  end

  def ydb
    require 'yaml'
    require 'yaml/store'
    @pdb ||= YAML::Store.new(File.join(Iam.base_dir, 'main.pstore.yml'))
  end

  def db_keys
    @pdb.transaction { pstore.roots }
  end

  def db_hash
    keys = pstore_keys
    @pdb.transaction { keys.inject({}) {|h,e| h[e] = @pdb[e]; h } }
  end
end
  