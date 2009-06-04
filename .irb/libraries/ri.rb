module Ri
  def self.init
    #using rdoc-2.3.0
    require 'rdoc/ri/driver'
    require 'libraries/hirb'
  end

  def ri(query)
    if query =~ /::|\#|\./
      system_ri(query)
    else
      ri_driver = RDoc::RI::Driver.new(RDoc::RI::Driver.process_args([query]))
      if ri_driver.class_cache.key?(query)
        ri_driver.display_class(query)
      else
        results = ri_driver.select_methods(/#{query}/)
        if (chosen = ::Hirb::Helpers::Menu.render(results, :fields=>['full_name'], :choose=>:one))
          system_ri(chosen['full_name'])
        end
      end
    end
    nil
  end

  def system_ri(*queries)
    RDoc::RI::Driver.run(queries)
  end
end