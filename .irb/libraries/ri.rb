module Ri
  def self.init
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
        chosen = ::Hirb::Helpers::Menu.render results, :fields=>['full_name']
        system_ri(chosen[0]['full_name']) if chosen.size == 1
      end
    end
    nil
  end

  def system_ri(*queries)
    RDoc::RI::Driver.run(queries)
  end
end