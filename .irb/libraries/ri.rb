module Ri
  def self.init
    #using rdoc-2.3.0
    require 'rdoc/ri/driver'
    require 'libraries/hirb'
  end

  def ri(query)
    query = query.to_s
    if query =~ /::|\#|\./
      system_ri(query)
    else
      ri_driver = RDoc::RI::Driver.new(RDoc::RI::Driver.process_args([query]))
      if ri_driver.class_cache.key?(query)
        ri_driver.display_class(query)
        if (class_cache = ri_driver.class_cache[query])
          methods = []
          class_cache["class_methods"].map {|e| e["name"]}.each {|e|
            methods << {:name=>"#{query}.#{e}", :type=>:class}
          }
          class_cache["instance_methods"].map {|e| e["name"]}.each {|e|
            methods << {:name=>"#{query}.#{e}", :type=>:instance}
          }
          ::Hirb::Helpers::Menu.render(methods, :fields=>[:name, :type]) do |chosen|
            system_ri(*chosen.map {|e| e[:name]})
          end
        end
      else
        results = ri_driver.select_methods(/#{query}/)
        ::Hirb::Helpers::Menu.render(results, :fields=>['full_name']) do |chosen|
          system_ri(*chosen.map {|e| e['full_name']})
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