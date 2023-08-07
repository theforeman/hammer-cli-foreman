require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/smart_proxy'

describe HammerCLIForeman::SmartProxy do

  include CommandTestHelper

  describe "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:smart_proxies, :index, [])
    end

    let(:cmd) { HammerCLIForeman::SmartProxy::ListCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    describe "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns  ["Id", "Name", "URL"]
    end

  end


  describe "InfoCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::InfoCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=proxy"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    describe "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "URL", "Features", "Created at", "Updated at"]
      end
    end

  end


  describe "CreateCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::CreateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name and url", ["--name=proxy", "--url=localhost"]
      # it_should_fail_with "name missing",     ["--url=localhost"]
      # it_should_fail_with "url missing",  ["--name=proxy"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  describe "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::DeleteCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=proxy"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  describe "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::UpdateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1", "--new-name=proxy2", "--url=localhost"]
      it_should_accept "name", ["--name=proxy", "--new-name=proxy2", "--url=localhost"]
      # it_should_fail_with "no params", []
      # it_should_fail_with "name or id missing", ["--new-name=proxy2"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  describe "RefreshFeaturesCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::RefreshFeaturesCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=proxy"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

end
