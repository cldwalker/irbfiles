__END__
require 'mongo_mapper'
MongoMapper.connection = Mongo::Connection.new
MongoMapper.database = 'mm-sample'
# require 'taggable'

class ::Url
  include MongoMapper::Document
  # include Taggable
  many :tags, :as=>:taggable
  key :name, String, :required => true
  timestamps!
end

class ::Tag 
  include MongoMapper::Document
  belongs_to :taggable, :polymorphic => true
  key :taggable_type, String
  key :taggable_id, ObjectId 
  key :name, String, :required => true 
end

class ::Tag
  include MongoMapper::EmbeddedDocument
  key :name
end

# could also try http://mongotips.com/b/array-keys-allow-for-modeling-simplicity/
