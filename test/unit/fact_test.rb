require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Fact do

  extend CommandTestHelper

  before :each do
    HammerCLI::Connection.drop_all
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource.resource_class)
    cmd.stubs(:name_to_id).returns(1)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Fact::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      it_should_print_n_records 2
      it_should_print_column "Host"
      it_should_print_column "Fact"
      it_should_print_column "Value"
    end

  end

end
