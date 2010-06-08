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
    Hirb.enable(enable_options)
    Hirb.add_dynamic_view("RDF::Query::Solution", :helper=>:auto_table) {|obj| {:fields=>obj.to_a.map {|e| e[0] } } }
    Hirb::Helpers::Table.filter_classes[Array] = [:join, ',']
  end

  def self.enable_options
    options = {:output=>output_config}
    options[:output_method] = "Mini.output" if !Object.const_defined?(:IRB) && Object.const_defined?(:Mini)
    options
  end

  def self.output_config
    {
      "IRB::History"=>{:class=>"Hirb::Helpers::Table", :output_method=>lambda {|l| 
        l.instance_eval("@contents").map {|e| [e[0], e[1].inspect.gsub("\n", '\n')]} },
        :options=>{:headers=>{0=>'statement_num',1=>'output'}} },
    }
  end
end