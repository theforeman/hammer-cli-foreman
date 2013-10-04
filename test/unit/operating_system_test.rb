require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::OperatingSystem do

  let(:ctx) { { :adapter => :silent } }

  extend CommandTestHelper

  before :each do
    resource_mock = ApipieResourceMock.new(cmd.class.resource.resource_class)
    resource_mock.stubs(:index).returns([[], nil])
    resource_mock.stubs(:show).returns([{"operatingsystem" => {}}, nil])
    cmd.class.resource resource_mock
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index)[0].length }

      it_should_print_n_records
      it_should_print_column "Name"
      it_should_print_column "Id"
      it_should_print_column "Release name"
      it_should_print_column "Family"
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::InfoCommand.new("", ctx) }

    before :each do
      HammerCLIForeman::Parameter.stubs(:get_parameters).returns([])
    end

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "label", ["--label=os"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Id"
        it_should_print_column "Release name"
        it_should_print_column "Family"
        it_should_print_column "Installation media"
        it_should_print_column "Architectures"
        it_should_print_column "Partition tables"
        it_should_print_column "Config templates"
        it_should_print_column "Parameters"
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, major, minor, family, release name", ["--name=media", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"]
      it_should_fail_with "name missing", ["--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"]
    end

    with_params ["--name=os", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"] do
      it_should_call_action :create, {'operatingsystem' => {'name' => 'os', 'major' => '1', 'minor' => '2', 'release_name' => 'awesome', 'family'=>"Red Hat"}}
    end
  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "label", ["--label=os"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "label", ["--label=os"]
      it_should_accept "id", ["--id=1"]
      it_should_accept "name, major, minor, family, release name", ["--id=83", "--name=os", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"]
      it_should_fail_with "no params", []
      it_should_fail_with "label or id missing", ["--name=os", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"]
    end

    with_params ["--id=83", "--name=os", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"] do
      it_should_call_action :update, {'id' => '83', 'operatingsystem' => {'name' => 'os', 'major' => '1', 'minor' => '2', 'release_name' => 'awesome', 'family'=>"Red Hat"}}
    end

  end


  context "SetParameterCommand" do

    before :each do
      resource_mock = ApipieResourceMock.new(cmd.class.resource.resource_class)
      resource_mock.stubs(:index).returns([[],""])
      cmd.class.resource resource_mock
    end

    let(:cmd) { HammerCLIForeman::OperatingSystem::SetParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, value and os id", ["--name=name", "--value=val", "--os-id=id"]
      it_should_fail_with "name missing", ["--value=val", "--os-id=id"]
      it_should_fail_with "value missing", ["--name=name", "--os-id=id"]
      it_should_fail_with "os id missing", ["--name=name", "--value=val"]
    end

  end


  context "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::DeleteParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name and os id", ["--name=domain", "--os-id=id"]
      it_should_fail_with "name missing", ["--os-id=id"]
      it_should_fail_with "os id missing", ["--name=name"]
    end

  end

end
