module HirbLib
  # Toggles hirb between being enabled and disabled
  def toggle_hirb
    Hirb::View.enabled? ? Hirb.disable : Hirb.enable
  end

  #@render_options :change_fields=>%w{class config}
  # Displays view config for each class
  def hirb_config
    Hirb::View.formatter_config
  end

  def self.after_included
    Hirb.add_dynamic_view("RDF::Query::Solution", :helper=>:auto_table) {|obj| {:fields=>obj.to_a.map {|e| e[0] } } }
    Hirb::Helpers::Table.filter_classes[Array] = [:join, ',']
  end
end

class ::Hirb::Helpers::ActiveRecordErrors < ::Hirb::Helpers::AutoTable
  def self.render(obj, options={})
    obj = obj.keys.inject({}) {|h,e|
      h.merge! e=>obj[e]
    }
    super obj, :change_fields=>[:attribute, :value]
  end
end
