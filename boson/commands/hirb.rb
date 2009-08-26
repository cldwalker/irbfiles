module Boson::Commands::Hirb
  def toggle_hirb
    Hirb::View.enabled? ? Hirb.disable : Hirb.enable(enable_options)
  end

  private
  def setup_hirb
    Hirb.disable if Hirb::View.enabled?
    Hirb.enable(enable_options)
  end

  def enable_options
    @enable_options = {:config_file=>File.join(Boson.dir, 'config', 'hirb.yml'), :output=>output_config}
    @enable_options[:output_method] = "Mini.output" unless Object.const_defined?(:IRB)
    @enable_options
  end

  def output_config
    {
      "IRB::History"=>{:class=>"Hirb::Helpers::Table", :output_method=>lambda {|l| 
        l.instance_eval("@contents").map {|e| [e[0], e[1].inspect.gsub("\n", '\n')]} },
        :options=>{:headers=>{0=>'statement_num',1=>'output'}} },
    }
  end
end
