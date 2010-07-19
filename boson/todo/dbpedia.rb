# Unfinished attempt at querying dbpedia
module Dbpedia
  # @options :resource=>'Honda_Legend', :property=>'engine', :browser=>:boolean,
  #   :property_type=>{:values=>%w{property ontology}, :default=>'property'}
  # Value for a given dbpedia resource's property
  def dbpedia_object(options={})
    sparql = %[
      PREFIX dbr: <http://dbpedia.org/resource/>
      PREFIX dbp: <http://dbpedia.org/#{options[:property_type]}/>
       
      SELECT ?class
      WHERE {
             dbr:#{options[:resource]} dbp:#{options[:property]} ?class .
      }
    ]
    sparql = %[
      SELECT DISTINCT ?predicate 
      WHERE {
          ?s ?predicate ?o.
      }
    ]
    url = build_url 'http://dbpedia.org/sparql', :query=>sparql.strip, :format=>options[:browser] ? '' : 'json'
    if options[:browser]
      browser url
    elsif (hash = get(url, :parse=>:json))
      key = hash['head']['vars'][0]
      hash['results']['bindings'].map {|e| e[key]['value'] }
    end
  end
end
