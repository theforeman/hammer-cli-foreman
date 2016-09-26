require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/audit'

describe HammerCLIForeman::Audit do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:audits, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Audit::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column "Id"
      it_should_print_column "At"
      it_should_print_column "IP"
      it_should_print_column "User"
      it_should_print_column "Action"
      it_should_print_column "Audit type"
      it_should_print_column "Audit record"
    end

  end


  context "InfoCommand" do
     before do
        cmd.stubs(:extend_data)
    end

    let(:cmd) { HammerCLIForeman::Audit::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Id"
        it_should_print_column "At"
        it_should_print_column "IP"
        it_should_print_column "User"
        it_should_print_column "Action"
        it_should_print_column "Audit type"
        it_should_print_column "Audit record"
        it_should_print_column "Audited changes"
      end
    end

  end
end
