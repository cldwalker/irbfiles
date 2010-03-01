__END__
require 'sequel'

::DB = ::Sequel.sqlite

::DB.create_table :dogs do
  primary_key :id
  String :name
end

class ::Dog < ::Sequel::Model
end
