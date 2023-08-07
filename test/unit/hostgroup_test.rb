require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/hostgroup'

describe HammerCLIForeman::Hostgroup do

  include CommandTestHelper

  describe "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:hostgroups, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Hostgroup::ListCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    describe "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "Title", "Operating System"]
      it_should_print_columns ["Model"]
    end

  end

  describe "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::InfoCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    describe "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Title"]
        it_should_print_columns ["Parameters", "Description"]
        it_should_print_columns ["Network", "Operating system"]
      end
    end

  end

  describe "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::DeleteCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  describe "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::CreateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name, parent_id, architecture_id, domain_id, operatingsystem_id and more",
          ["--name=hostgroup", "--parent-id=1", "--architecture-id=1", "--domain-id=1",
            "--operatingsystem-id=1", "--medium-id=1", "--partition-table-id=1", "--subnet-id=1", '--root-password=foreman']
      # it_should_fail_with "name or id missing",
      #    ["--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1"]
      # TODO: temporarily disabled, parameters are checked in the api
    end
  end

  describe "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::UpdateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name, parent_id, architecture_id, domain_id, operatingsystem_id and more",
          ["--id=1 --name=hostgroup2 --title=default/hostgroup2", "--parent-id=1", "--architecture-id=1", "--domain-id=1",
            "--operatingsystem-id=1", "--medium-id=1", "--partition-table-id=1", "--subnet-id=1", '--root-password=foreman']
      # it_should_fail_with "no params", []
      # it_should_fail_with "id missing", ["--name=host2"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  describe "SetParameterCommand" do

    before :each do
      ResourceMocks.parameters_index
    end

    let(:cmd) { HammerCLIForeman::Hostgroup::SetParameterCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name, value, parameter-type and hostgroup id", ["--name=name", "--parameter-type=string", "--value=val", "--hostgroup-id=1"]
      it_should_fail_with "name missing", ["--value=val", "--hostgroup-id=1"]
      it_should_fail_with "value missing", ["--name=name", "--hostgroup-id=1"]
      # it_should_fail_with "hostgroup id missing", ["--name=name", "--value=val"] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  describe "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::DeleteParameterCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name and hostgroup id", ["--name=param", "--hostgroup-id=1"]
      # it_should_fail_with "name missing", ["--hostgroup-id=id"]
      # it_should_fail_with "hostgroup id missing", ["--name=param"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  describe "RebuildConfigCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::RebuildConfigCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver

    end
  end

end
