__END__
require 'dm-core'
::DataMapper.setup(:default, 'sqlite3::memory:')

class Url
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :desc, String
  has n, :tags
end

class Tag
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  belongs_to :url
end

Url.auto_migrate!
Tag.auto_migrate!