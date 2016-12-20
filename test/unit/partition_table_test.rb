require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/partition_table'

describe HammerCLIForeman::PartitionTable do


  include CommandTestHelper

  before :each do
    cmd.stubs(:get_identifier).returns(1)

    ::File.stubs(:read).returns("FILE_CONTENT")
  end

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:ptables, :index, [])
    end

    let(:cmd) { HammerCLIForeman::PartitionTable::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "OS Family"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=ptable"]

      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "OS Family", "Created at", "Updated at"]
      end
    end

    with_params ["--id=83"] do
      it_should_call_action :show, {'id' => '83'}
    end

    with_params ["--name=ptable"] do
      it_should_call_action :show, {'id' => 1}
    end

  end


  context "DumpCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::DumpCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=ptable"]
      # it_should_fail_with "id or name missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    with_params ["--id=83"] do
      it_should_call_action :show, {'id' => '83'}
    end

    with_params ["--name=ptable"] do
      it_should_call_action :show, {'id' => 1}
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::CreateCommand.new("", ctx) }

    before :each do
      cmd.stubs(:template_kind_id).returns(1)
    end

    context "parameters" do
      it_should_accept "name, file, os family", ["--name=tpl", "--file=~/table.sh", "--os-family=RedHat"]
      # it_should_fail_with "name missing", ["--file=~/table.sh", "--os-family=RedHat"]
      # it_should_fail_with "file missing", ["--name=tpl", "--os-family=RedHat"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

    with_params ["--name=ptable","--file=~/table.sh", "--os-family=RedHat"] do
      it_should_call_action :create, {'ptable' => {'name' => 'ptable', 'layout' => 'FILE_CONTENT', 'os_family' => 'RedHat'}}
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id, new-name, file, type, audit comment, os ids", ["--id=83", "--new-name=ptable","--file=~/table.sh", "--os-family=RedHat"]
      it_should_accept "name, new-name, file, type, audit comment, os ids", ["--name=ptable", "--new-name=ptable2", "--file=~/table.sh", "--os-family=RedHat"]
      # it_should_fail_with "id and name missing", ["--new-name=ptable","--file=~/table.sh", "--os-family=RedHat"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    with_params ["--id=83", "--new-name=ptable","--file=~/table.sh", "--os-family=RedHat"] do
      it_should_call_action :update, {'id' => '83', 'name' => 'ptable', 'ptable' => {'name' => 'ptable', 'layout' => 'FILE_CONTENT', 'os_family' => 'RedHat'}}
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=ptable"]
      # it_should_fail_with "id or name missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    with_params ["--id=1"] do
      it_should_call_action :destroy, {'id' => '1'}
    end

    with_params ["--name=ptable"] do
      it_should_call_action :destroy, {'id' => 1}
    end

  end

end
