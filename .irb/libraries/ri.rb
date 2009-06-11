module Ri
  def self.included(mod)
    #using rdoc-2.3.0
    require 'rdoc/ri/driver'
    require 'libraries/hirb'
  end

  def ri(original_query, regex=nil)
    query = original_query.to_s
    if query =~ /::|\#|\./
      system_ri(query)
    else
      if original_query.is_a?(Class) && regex
        methods = []
        original_query.methods(nil).grep(regex).sort.each {|e| methods << {:name=>"#{original_query}::#{e}", :type=>:class} }
        original_query.instance_methods(nil).grep(regex).sort.each {|e| methods << {:name=>"#{original_query}##{e}", :type=>:instance} }
        ::Hirb::Helpers::Menu.render(methods, :fields=>[:name, :type], :ask=>false) do |chosen|
          system_ri(*chosen.map {|e| e[:name]})
        end
      else
        ri_driver = RDoc::RI::Driver.new(RDoc::RI::Driver.process_args([query]))
        if ri_driver.class_cache.key?(query)
          ri_driver.display_class(query)
        else
          results = ri_driver.select_methods(/#{query}/)
          ::Hirb::Helpers::Menu.render(results, :fields=>['full_name'], :ask=>false) do |chosen|
            system_ri(*chosen.map {|e| e['full_name']})
          end
        end
      end
    end
    nil
  end

  def system_ri(*queries)
    RDoc::RI::Driver.run(queries)
  rescue SystemExit
  end
end