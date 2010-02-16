# Allows passing fields to usage_options i.e. commands -hv -u=f:* # or -u=f:name.alias
class ::Boson::OptionParser
  alias_method :old_get_usage_fields, :get_usage_fields

  def get_usage_fields(fields)
    if fields
      default_fields = [:name, :alias, :type]
      all_fields = option_attributes.map {|k,v| v.keys }.flatten.uniq + default_fields
      fields = fields == '*' ? all_fields :
        fields.split('.').map {|e| Util.underscore_search(e, all_fields.sort_by {|f| f.to_s}, true) }
      fields.uniq
    else
      old_get_usage_fields(fields)
    end
  end
end