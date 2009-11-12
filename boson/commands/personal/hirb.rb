module HirbLib
  # Toggles hirb between being enabled and disabled
  def toggle_hirb
    Hirb::View.enabled? ? Hirb.disable : Hirb.enable(HirbLib.enable_options)
  end

  #@render_options :filters=>{:default=>{1=>:inspect}}
  def hirb_config
    Hirb::View.formatter_config
  end

  def self.after_included
    Hirb.disable if Hirb::View.enabled?
    Hirb.enable(enable_options)
  end

  def self.enable_options
    options = {:config_file=>File.join(Boson.repo.config_dir, 'hirb.yml'), :output=>output_config}
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