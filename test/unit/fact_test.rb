require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/fact'

describe HammerCLIForeman::Fact do

  include CommandTestHelper

  describe "ListCommand" do

    let(:cmd) { HammerCLIForeman::Fact::ListCommand.new("", ctx) }

    before(:each) do
      ResourceMocks.facts_index
    end

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    describe "output" do
      it_should_print_column "Host"
      it_should_print_column "Fact"
      it_should_print_column "Value"
    end

  end

end
