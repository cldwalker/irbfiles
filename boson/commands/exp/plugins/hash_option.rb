# Tweaks to hash option
class ::Boson::OptionParser
  # Allow for aliasing hash :values with a :values attribute
  def create_hash(value)
    hash = super
    if (values = current_attributes[:values])
      values = values.sort_by {|e| e.to_s }
      hash = hash.inject({}) {|h,(k,v)|
        h[k] = auto_alias_value(values,v); h
      }
      validate_enum_values(values, hash.values)
    end
    hash
  end

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