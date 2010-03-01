__END__
require 'sequel'

::DB = ::Sequel.sqlite

::DB.create_table :urls do
  primary_key :id
  String :name
end

class ::Url < ::Sequel::Model
end
