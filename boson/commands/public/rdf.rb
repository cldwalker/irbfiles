module RdfLib
  def self.included(mod)
    require 'rdf'
  end

  # @render_options :change_fields=>[:subject, :predicate, :object]
  # Parse and display an rdf file in a variety of formats
  def dump_rdf(uri)
    require 'rdf/ntriples' if uri[/\.nt$/]
    require 'rdf/json' if uri[/\.json$/]
    require 'rdf/raptor' if uri[/\.(rdf|ttl)$/]
    RDF::Graph.load(uri).data.map {|e| e.to_a }
  end
end
