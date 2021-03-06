module RdfLib
  def self.append_features(mod)
    require 'rdf'
    super
  rescue LoadError
    false
  end

  def self.included(mod)
    ::RDF::Query.module_eval %[class StringVariable < Variable; def to_s; @name; end; end]
  end

  # @render_options :change_fields=>[:subject, :predicate, :object]
  # Parse and display an rdf file in a variety of formats
  def dump_rdf(uri)
    require 'rdf/ntriples' if uri[/\.nt$/]
    require 'rdf/json' if uri[/\.json$/]
    require 'rdf/raptor' if uri[/\.(rdf|ttl)$/]
    require 'rdf/n3' if uri[/\.(n3)$/]
    RDF::Graph.load(uri).data.map {|e| e.to_a }
  end

  ENDPOINTS = {
    'bio'=>'http://hcls.deri.org/sparql', 'space'=>'http://api.talis.com/stores/space/services/sparql',
    'gov'=>'http://semantic.data.gov/sparql', 'dbp'=>'http://dbpedia.org/sparql',
    'med'=>'http://www4.wiwiss.fu-berlin.de/dailymed/sparql', 'movie'=>'http://data.linkedmdb.org/sparql',
    'music'=>'http://dbtune.org/musicbrainz/sparql', 'sparql'=>'http://www.sparql.org/sparql',
    'bmark' => 'http://dydra.com/cldwalker/bookmarks/sparql'
  }

  # @render_options :change_fields=>['name', 'url']
  # Display endpoints
  def endpoints
    ENDPOINTS
  end

  # @option :type, :default=>'classes', :desc=>'Executes a predefined query type',
  #   :values=>%w{classes objects resource predicates subjects all}
  # @option :limit, :type=>:numeric, :desc=>'Adds limit to query'
  # @option :offset, :type=>:numeric, :desc=>'Adds offset to query'
  # @option :filters, :type=>:hash, :desc=>'Takes variable names and adds regex filters on them'
  # @option :sparql, :type=>:string, :desc=>'Specify a predefined query or allow raw sparql',
  #   :values=>%w{graphs select}, :bool_default=>true
  # @option :abbreviate, :type=>:boolean, :desc=>'Abbreviates uris'
  # @option :endpoint, :desc=>'Endpoint to query', :values=> ENDPOINTS.keys, :enum=>false,
  #   :default=>'http://api.talis.com/stores/space/services/sparql'
  # @option :return_sparql, :type=>:boolean, :desc=>'Prints sparql that would be executed'
  # @option :prefix, :type=>:boolean, :desc=>'Adds prefixes to query'
  # @render_options {}
  # Query and explore a sparql endpoint
  def sparql(*args)
    @options = options = args[-1].is_a?(Hash) ? args.pop : {}
    options[:endpoint] = ENDPOINTS[options[:endpoint]] || options[:endpoint]
    require 'sparql/client'
    qoptions = options[:endpoint][/dydra/] ? {:headers => {"Authorization" => "Basic #{basic_authify}"}} : {}
    client = SPARQL::Client.new(options[:endpoint], qoptions)

    if options[:sparql]
      spl = select_sparql(options[:sparql], args)
      if options[:prefix]
        spl = NAMESPACES.map {|k,v| "PREFIX #{k}: <#{v}>" }.join("\n") + "\n" + spl
      end
      return puts(spl) if options[:return_sparql]
      solutions = client.query(spl)
    else
      query = select_query(client, options[:type], args)
      query.limit(options[:limit]) if options[:limit]
      query.offset(options[:offset]) if options[:offset]
      if options[:filters]
        if options[:type] == 'predicates'
          options[:filters].each {|k,v| options[:filters][k] = NAMESPACES[v] || v }
        end
        options[:filters].each {|k,v|
          query.filter("regex(str(?#{k}), '#{v}', 'i')")
        }
      end
      if options[:prefix]
        NAMESPACES.each {|k,v| query.prefix("#{k}: <#{v}>") }
      end
      return puts(query.to_s) if options[:return_sparql]
      solutions = query.solutions
    end

    results = solutions && solutions.map {|e| e.to_hash }
    abbreviate_uris(results) if options[:abbreviate]
    results
  end

  def basic_authify
    ["#{ENV['DYDRA_USER']}:#{ENV['DYDRA_PASSWORD']}"].pack('m').strip
  end

  def select_sparql(sparql_type, args)
    # %[SELECT DISTINCT ?x { [] a ?x }]
    if sparql_type == 'graphs'
      %[SELECT DISTINCT ?g WHERE {
        GRAPH ?g { [] a ?Concept }
      }]
    elsif sparql_type == 'select'
      args = args.join(' ').split(/\s+/).map {|e| e[/^http/] ? "<#{e}>" : e }
      "SELECT * WHERE { #{args.join(' ')} }"
    else
      args.join(' ')
    end
  end

  def create_rdf_value(str)
    @options[:prefix] ? RDF::Query::StringVariable.new(str) : RDF::URI.new(str)
  end

  def select_query(client, query_type, args)
    case query_type
    when 'classes'
      client.select(:o).where([:s,RDF.type,:o]).distinct
    when 'subjects'
      args[0] ?  client.select(:s).where([:s, RDF.type, create_rdf_value(args[0])]).distinct :
        client.select(:s).where([:s, :p, :o]).distinct
    when 'objects'
      args[0] ?  client.select(:o).where([create_rdf_value(args[0]), :p, :o]).where([:o, RDF.type, :x]).distinct :
        client.select(:o).where([:s, :p, :o]).distinct
    when 'predicates'
      args[0] ?  client.select(:p).where([:s, :p, create_rdf_value(args[0])]).distinct :
        client.select(:p).where([:s, :p, :o]).distinct
    when 'resource'
      client.select(:p, :o).where([create_rdf_value(args[0]), :p, :o])
    else
      client.select(:s, :p, :o).where([:s, :p, :o])
    end
  end

  NAMESPACES = {
    'foaf'=>'http://xmlns.com/foaf/0.1/',
    'dc'=>'http://purl.org/dc/terms/',
    'geo'=>'http://www.w3.org/2003/01/geo/wgs84_pos#',
    'rdfs'=>'http://www.w3.org/2000/01/rdf-schema#',
    'owl'=>'http://www.w3.org/2002/07/owl#',
    'rdf'=>'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    'dbp'=>'http://dbpedia.org/property/',
    'skos'=>'http://www.w3.org/2004/02/skos/core#',
    'xsd'=>'http://www.w3.org/2001/XMLSchema#',
    'sioc'=>'http://rdfs.org/sioc/ns#',
    'po'=>'http://purl.org/ontology/po/',
    'space'=>'http://purl.org/net/schemas/space/',
    'fb'=>'http://rdf.freebase.com/ns/',
    'movie'=>'http://data.linkedmdb.org/resource/movie/'
  }

  # @render_options :change_fields=>['name', 'url']
  # Display endpoints
  def rdf_namespaces
    NAMESPACES
  end

  def open_namespace(namespace)
    browser NAMESPACES[namespace]
  end

  def abbreviate_uris(arr)
    arr.each {|e|
      e.each {|k,v|
        if v.is_a?(RDF::URI) && (match = NAMESPACES.find {|abbr,uri| v.to_s[/^#{uri}/] })
          e[k] = v.to_s.sub(/^#{match[1]}/,match[0]+":")
        elsif v.is_a?(RDF::Literal)
          e[k] = v.to_s.sub(/\^\^.*$/, '')
        end
      }
    }
  end
end
