__END__
require 'couch_potato'
CouchPotato::Config.database_name = 'urls'
class Url
  include CouchPotato::Persistence
  property :name
  view :all, :key=>:name
end

u1 = Url.new :name=>'aaa.com'
CouchPotato.database.save_document u1

require 'couch_foo'
CouchFoo::Base.set_database(:host => "http://localhost:5984", :database=>'urls')
class Url < CouchFoo::Base
  property :name, String
end

require 'couchrest'
@db = CouchRest.database("http://127.0.0.1:5984/urls")
class Url < CouchRest::ExtendedDocument
  property :name
  view_by :name
end
Url.database = @db
