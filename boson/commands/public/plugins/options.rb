class ::Boson::OptionParser
  # Allows for boolean values in hashes
  def parse_hash(value, keys)
    if value[/:$/]
      splitter = current_attributes[:split] || ','
      value.gsub(/:$/, '').split(/#{Regexp.quote(splitter)}/).inject({}) {|t,e|
        key = keys ? auto_alias_value(keys, e) : e
        t[key] = true; t
      }
    else
      super
    end
  end
end

# it "with value ending in ':' assumes true value" do
#   parse('-e', 'tw,o:')[:e].should == {:two=>true, :one=>true}
# end

module ::Boson::Options::Date
  def create_date(value)
   Date.parse(value + "/#{Date.today.year}")
  end

  def usage_for_date(opt)
    default_usage opt, "MM/DD"
  end
end

module OptionsLib
  def self.after_included
   ::Boson::OptionParser.send :include, ::Boson::Options::Date
  end
end
