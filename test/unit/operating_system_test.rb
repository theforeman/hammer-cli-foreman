require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/operating_system'

describe HammerCLIForeman::OperatingSystem do

  include CommandTestHelper

  describe "ListCommand" do

    before :each do
      ResourceMocks.operatingsystems
    end

    let(:cmd) { HammerCLIForeman::OperatingSystem::ListCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
      it_should_accept 'organization', ['--organization-id=1']
      it_should_accept 'location', ['--location-id=1']
    end

    describe "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column "Title"
      it_should_print_column "Id"
      it_should_print_column "Release name"
      it_should_print_column "Family"
    end

  end


  describe "InfoCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::InfoCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "title", ["--title=Rhel 6.5"]
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    describe "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Title"
        it_should_print_column "Id"
        it_should_print_column "Major version"
        it_should_print_column "Minor version"
        it_should_print_column "Release name"
        it_should_print_column "Family"
        it_should_print_column "Installation media"
        it_should_print_column "Architectures"
        it_should_print_column "Partition tables"
        it_should_print_column "Templates"
        it_should_print_column "Default templates"
        it_should_print_column "Parameters"
      end
    end
  end


  describe "CreateCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::CreateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name, major, minor, family, release name, organization, location",
                       ["--name=media", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome", "--organization-id=1", "--location-id=1"]
      # it_should_fail_with "name missing", ["--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

    with_params ["--name=os", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"] do
      it_should_call_action :create, {'operatingsystem' => {'name' => 'os', 'major' => '1', 'minor' => '2', 'release_name' => 'awesome', 'family'=>"Red Hat"}}
    end
  end


  describe "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::DeleteCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "title", ["--title=Rhel 6.5"]
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  describe "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::UpdateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "title", ["--title=Rhel 6.5"]
      it_should_accept "name, major, minor, family, release name, organization, location",
                       ["--id=83", "--name=os", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome", "--organization-id=1", "--location-id=1"]
      # it_should_fail_with "no params", []
      # it_should_fail_with "label or id missing", ["--name=os", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    with_params ["--id=83", "--name=os", "--major=1", "--minor=2", "--family=Red Hat", "--release-name=awesome"] do
      it_should_call_action :update, {'id' => '83', 'operatingsystem' => {'name' => 'os', 'major' => '1', 'minor' => '2', 'release_name' => 'awesome', 'family'=>"Red Hat"}}
    end

  end


  describe "SetParameterCommand" do

    before :each do
      ResourceMocks.operatingsystems
    end

    let(:cmd) { HammerCLIForeman::OperatingSystem::SetParameterCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name, value and os id", ["--name=domain", "--value=val", "--operatingsystem-id=1"]
      it_should_accept "name, value and os title", ["--name=domain", "--value=val", "--operatingsystem=Rhel 6.5"]
      it_should_accept "name, value, type and os id", ["--name=domain", "--value=val", "--parameter-type=string", "--operatingsystem-id=1"]
      # it_should_fail_with "name missing", ["--value=val", "--operatingsystem-id=id"]
      # it_should_fail_with "value missing", ["--name=name", "--operatingsystem-id=id"]
      # it_should_fail_with "os id missing", ["--name=name", "--value=val"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  describe "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::OperatingSystem::DeleteParameterCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name and os id", ["--name=domain", "--operatingsystem-id=1"]
      it_should_accept "name and os title", ["--name=domain", "--operatingsystem=Rhel 6.5"]
      # it_should_fail_with "name missing", ["--operatingsystem-id=id"]
      # it_should_fail_with "os id missing", ["--name=name"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end
end
