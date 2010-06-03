module RdfLib
  def self.included(mod)
    require 'rdf'
  end

  # @render_options :change_fields=>[:subject, :predicate, :object]
  # @options :format=>''
  # Parse and display an rdf file in a variety of formats
  def dump_rdf(uri, options={})
    require 'rdf/ntriples' if uri[/\.nt$/]
    require 'rdf/json' if uri[/\.json$/]
    require 'rdf/raptor' if uri[/\.(rdf|ttl)$/] || options[:format][/rdf|ttl/]
    RDF::Graph.load(uri).data.map {|e| e.to_a }
  end

  # @options :type=>{:default=>'classes', :values=>%w{classes objects show_object properties} },
  #   :endpoint=>'http://api.talis.com/stores/space/services/sparql', :limit=>:numeric
  # Query and explore a sparql endpoint
  def sparql(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    require 'sparql/client'
    client = SPARQL::Client.new(options[:endpoint])
    if options[:sparql]
      # %[SELECT DISTINCT ?x { [] a ?x }]
      solutions = client.query(args.join(' '))
    else
      query = case options[:type]
      when 'classes'
        client.select(:o).where([:s,RDF.type,:o]).distinct
      when 'objects'
        # http://purl.org/net/schemas/space/LaunchSite
        args[0] ?  client.select(:s).where([:s, RDF.type, RDF::URI.new(args[0])]).distinct :
          client.select(:s).where([:s, :p, :o]).distinct
      when 'properties'
        client.select(:p).where([:s, :p, :o]).distinct
      when 'show_object'
        # http://nasa.dataincubator.org/launchsite/capecanaveral
        client.select(:p, :o).where([RDF::URI.new(args[0]), :p, :o])
      end
      query.limit(options[:limit]) if options[:limit]
      solutions = query.solutions
    end
    solutions && solutions.map {|e| e.to_hash }
  end
end
