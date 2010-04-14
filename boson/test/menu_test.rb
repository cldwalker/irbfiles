require File.join(File.dirname(__FILE__), 'test_helper')
require 'commands/exp/plugins/menu'
require 'boson'

class MenuTest < Test::Unit::TestCase
  def create_menu(options={})
    options = { :items=>[], :env=>{:global_options=>{}} }.merge options
    Menu.new(options[:items], {}, options[:env])
  end

  def run_menu(options={})
    create_menu(options).run
  end

  test "menu initialized" do
    mock(Boson).invoke
    run_menu(:items=>[1,2,3])
  end
end

