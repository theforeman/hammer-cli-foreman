require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::PartitionTable do

  extend CommandTestHelper

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource)

    File.stubs(:read).returns("FILE_CONTENT")
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::ListCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.index[0].length }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "OS Family"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::InfoCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=ptable"]
      it_should_fail_with "no arguments"
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
      it_should_call_action :show, {'id' => 'ptable'}
    end

  end


  context "DumpCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::DumpCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=ptable"]
      it_should_fail_with "id or name missing", []
    end

    with_params ["--id=83"] do
      it_should_call_action :show, {'id' => '83'}
    end

    with_params ["--name=ptable"] do
      it_should_call_action :show, {'id' => 'ptable'}
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::CreateCommand.new("") }

    before :each do
      cmd.stubs(:template_kind_id).returns(1)
    end

    context "parameters" do
      it_should_accept "name, file, os family", ["--name=tpl", "--file=~/table.sh", "--os-family=RedHat"]
      it_should_fail_with "name missing", ["--file=~/table.sh", "--os-family=RedHat"]
      it_should_fail_with "file missing", ["--name=tpl", "--os-family=RedHat"]
    end

    with_params ["--name=ptable","--file=~/table.sh", "--os-family=RedHat"] do
      it_should_call_action :create, {'ptable' => {'name' => 'ptable', 'layout' => 'FILE_CONTENT', 'os_family' => 'RedHat'}}
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::UpdateCommand.new("") }

    context "parameters" do
      it_should_accept "id, new-name, file, type, audit comment, os ids", ["--id=83", "--new-name=ptable","--file=~/table.sh", "--os-family=RedHat"]
      it_should_accept "name, new-name, file, type, audit comment, os ids", ["--name=ptable", "--new-name=ptable2", "--file=~/table.sh", "--os-family=RedHat"]
      it_should_fail_with "id and name missing", ["--new-name=ptable","--file=~/table.sh", "--os-family=RedHat"]
    end

    with_params ["--id=83", "--new-name=ptable","--file=~/table.sh", "--os-family=RedHat"] do
      it_should_call_action :update, {'id' => '83', 'ptable' => {'name' => 'ptable', 'layout' => 'FILE_CONTENT', 'os_family' => 'RedHat'}}
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::PartitionTable::DeleteCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=ptable"]
      it_should_fail_with "id or name missing", []
    end

    with_params ["--id=1"] do
      it_should_call_action :destroy, {'id' => '1'}
    end

    with_params ["--name=ptable"] do
      it_should_call_action :destroy, {'id' => 'ptable'}
    end

  end

end
