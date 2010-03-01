__END__
require 'mongoid'
Mongoid.configure {|c| c.master = Mongo::Connection.new.db('sample') }

class ::Url
  include Mongoid::Document
  field :name
  field :desc
  has_many :tags
end

class ::Tag
  include Mongoid::Document
  field :name
  field :desc
  belongs_to :url, :inverse_of=>:tags
end