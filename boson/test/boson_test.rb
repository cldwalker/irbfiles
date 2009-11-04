require File.join(File.dirname(__FILE__), 'test_helper')
require 'commands/public/boson'

# currently broken
class BosonTest < Test::Unit::TestCase
  before(:all) {
    @higgs = Object.new.extend ::BosonLib
    # # reset_boson
    # @higgs = Boson.main_object
    # ancestors = class <<Boson.main_object; self end.ancestors
    # # allows running just this test file
    # Library.load Runner.default_libraries unless ancestors.include?(Boson::Commands::Core)
  }

  test "unloaded_libraries detects libraries under commands directory" do
    Dir.stubs(:[]).returns(['./commands/lib.rb', './commands/lib2.rb'])
    @higgs.unloaded_libraries.should == ['lib', 'lib2']
  end

  test "unloaded_libraries detect libraries in :libraries config" do
    @higgs.unloaded_libraries.should == ['yada']
  end
end