__END__
require 'ripple'
class Url
  include Ripple::Document
  property :name, String
end

require 'friendly'
Friendly.configure :adapter  => "mysql", :host => "localhost", :user => "root",    :password => "",:database => "test"

class Url
  include Friendly::Document
  attribute :name, String
  indexes :name
end