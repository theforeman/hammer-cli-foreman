require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/config_report'

describe HammerCLIForeman::ConfigReport do

  include CommandTestHelper

  describe "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:config_reports, :index, [])
    end

    let(:cmd) { HammerCLIForeman::ConfigReport::ListCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    describe "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column "Id"
      it_should_print_column "Host"
      it_should_print_column "Origin"
      it_should_print_column "Last report"
      it_should_print_column "Applied"
      it_should_print_column "Restarted"
      it_should_print_column "Failed"
      it_should_print_column "Restart Failures"
      it_should_print_column "Skipped"
      it_should_print_column "Pending"
    end

  end


  describe "InfoCommand" do

    let(:cmd) { HammerCLIForeman::ConfigReport::InfoCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  describe "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::ConfigReport::DeleteCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


end
