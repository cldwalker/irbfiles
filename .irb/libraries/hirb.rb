module Boson::Libraries::Hirb
  def self.init
    require 'hirb'
    send :include, Hirb::Console
    Hirb::Helpers::Table.max_width = 210
  end
  
  def toggle_hirb
    Hirb::View.enabled? ? Hirb::View.disable : Hirb::View.enable {|c| c.output = output_config }
  end

  private
  def output_config
    {
      "IRB::History"=>{:class=>"Hirb::Helpers::Table", :output_method=>lambda {|l| 
        l.instance_eval("@contents").map {|e| [e[0], e[1].inspect.gsub("\n", '\n')]} },
        :options=>{:headers=>{0=>'statement_num',1=>'output'}} },
      'WWW::Delicious::Element'=>{:class=>'Hirb::Helpers::ObjectTable', :ancestor=>true},
      'WWW::Delicious::Bundle'=>{:options=>{:fields=>[:name, :tags]}},
      'WWW::Delicious::Tag'=>{:options=>{:fields=>[:name, :count]}},
      'WWW::Delicious::Post'=>{:options=>{:fields=>[:url, :notes, :time]}},
      # for google reader posts
      'OpenStruct'=>{:class=>"Hirb::Helpers::ObjectTable", :options=>{:fields=>[:title, :google_id]}}
    }
  end
end