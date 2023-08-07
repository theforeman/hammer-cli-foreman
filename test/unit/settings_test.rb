require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/settings'

describe HammerCLIForeman::Settings do

  include CommandTestHelper

  describe "ListCommand" do

    before do
      ResourceMocks.mock_action_call(:settings, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Settings::ListCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
      it_should_accept 'organization', ['--organization-id=1']
      it_should_accept 'location', ['--location-id=1']
    end

    describe "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column "Name"
      it_should_print_column "Full name"
      it_should_print_column "Value"
      it_should_print_column "Description"
    end

  end

  describe "UpdateCommand" do
    let(:cmd) { HammerCLIForeman::Settings::UpdateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=setting1", "--value=setting2"]
      it_should_accept "id", ["--id=1", "--value=setting2"]
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end

  end
end

