module Do
  def self.included(mod)
    require 'rdf'
    require 'rdf/ntriples'
    require 'data_objects'
    require 'do_sqlite3'
    require 'rdf/do'
  end

  def do_repo
    @do_repo ||= RDF::DataObjects::Repository.new('sqlite3:test.db')
  end

  # @config :option_command=>true
  def do_create(uri, pred, *desc)
    args = [ urize(uri), urize(pred), desc.join(' ') ]
    do_repo.insert(args)
  end

  def do_delete(*args)
    do_repo.delete  filter_query(*args)
  end

  def do_query(*args)
    do_repo.query filter_query(*args)
  end

  # @render_options :sort=>0
  def do_find(uri)
    do_repo.query(:subject=>::RDF::URI.new(uri)).inject(:_id=>uri) {|h,e|
      h[e.predicate.to_s] = e.object.to_s; h }
  end

  def do_list
    do_repo.to_a
  end

  private
  def filter_query(*args)
    query = args[0].is_a?(Hash) ? args[0] : {:subject=>args[0] }
    query.each {|k,v| query[k] = urize(v) }
    query
  end

  def urize(uri) 
    uri[/^http/] ? ::RDF::URI.new(uri) : uri
  end
end
