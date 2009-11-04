module Ri
  def self.included(mod)
    #using rdoc-2.3.0
    require 'rdoc/ri/driver'
  end

  # @desc Wraps around ri to provide a menu when there are multiple matches.
  # Enter * at menu prompt to view all matching methods.
  def ri(original_query, regex=nil)
    query = original_query.to_s
    if query =~ /::|\#|\./
      system_ri(query)
    else
      ri_driver = RDoc::RI::Driver.new(RDoc::RI::Driver.process_args([query]))
      if ri_driver.class_cache.key?(query) && original_query.is_a?(Symbol)
        ri_driver.display_class(query)
      elsif ri_driver.class_cache.key?(query)
        ri_driver.display_class(query)
        if (class_cache = ri_driver.class_cache[query])
          methods = []
          class_methods = class_cache["class_methods"].map {|e| e["name"]}
          instance_methods = class_cache["instance_methods"].map {|e| e["name"]}
          if regex
            class_methods = class_methods.grep(/#{regex}/)
            instance_methods = instance_methods.grep(/#{regex}/)
          end
          all_methods = class_methods.each {|e| methods << {:name=>"#{query}.#{e}", :type=>:class}} +
            instance_methods.each {|e| methods << {:name=>"#{query}.#{e}", :type=>:instance}}
          menu(methods, :fields=>[:name, :type]) do |chosen|
            system_ri(*chosen.map {|e| e[:name]})
          end
        end
      else
        results = ri_driver.select_methods(/#{query}/)
        menu(results, :fields=>['full_name'], :ask=>false) do |chosen|
          system_ri(*chosen.map {|e| e['full_name']})
        end
      end
    end
    nil
  end

  private
  def system_ri(*queries)
    ::Hirb::View.capture_and_render { RDoc::RI::Driver.run(queries) }
  rescue SystemExit
    invalid_method = $!.message[/\S+\s*$/]
    # retry query if invalid method detected
    system_ri(*queries) if queries.delete(invalid_method) && !queries.empty?
  end
end