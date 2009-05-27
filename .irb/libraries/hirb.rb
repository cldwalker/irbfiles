module Boson::Libraries::Hirb
  def self.init
    require 'hirb'
    send :include, Hirb::Console
    Hirb::Helpers::Table.max_width = 210
  end
  
  def toggle_hirb
    Hirb::View.enabled? ? Hirb::View.disable : Hirb::View.enable(:config_file=>File.join(Boson.base_dir, 'config',
      'hirb.yml')) {|c| c.output = output_config }
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