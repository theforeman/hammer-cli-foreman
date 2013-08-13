require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli_foreman/formatters'


describe "HammerCLIForeman::Formatters.date_formatter" do

  let(:formatter) {HammerCLIForeman::Formatters.method(:date_formatter)}

  it "should reformat date" do
    formatter.call("2013-06-08T18:53:56Z").must_equal "2013/06/08 18:53:56"
  end

  it "should return empty string for nil input" do
    formatter.call(nil).must_equal ""
  end

  it "should return empty string on errors" do
    formatter.call("NOT A DATE").must_equal ""
  end

end
