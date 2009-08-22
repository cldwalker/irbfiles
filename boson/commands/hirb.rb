module Boson::Commands::Hirb
  def self.included(mod)
    require 'hirb'
    mod.send :include, Hirb::Console
  end
  
  def toggle_hirb
    enable_options = {:config_file=>File.join(Boson.dir, 'config', 'hirb.yml'), :output=>output_config}
    enable_options[:output_method] = "Mini.output" unless Object.const_defined?(:IRB)
    Hirb::View.enabled? ? Hirb::View.disable : Hirb::View.enable(enable_options)
  end

  private
  def output_config
    {
      "IRB::History"=>{:class=>"Hirb::Helpers::Table", :output_method=>lambda {|l| 
        l.instance_eval("@contents").map {|e| [e[0], e[1].inspect.gsub("\n", '\n')]} },
        :options=>{:headers=>{0=>'statement_num',1=>'output'}} },
    }
  end
end
