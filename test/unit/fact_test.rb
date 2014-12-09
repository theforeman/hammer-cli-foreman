require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/fact'

describe HammerCLIForeman::Fact do

  include CommandTestHelper

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Fact::ListCommand.new("", ctx) }

    before(:each) do
      ResourceMocks.facts_index
    end

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      it_should_print_column "Host"
      it_should_print_column "Fact"
      it_should_print_column "Value"
    end

  end

end
