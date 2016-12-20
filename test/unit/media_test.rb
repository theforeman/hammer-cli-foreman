require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/media'

describe HammerCLIForeman::Medium do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:media, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Medium::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column "Name"
      it_should_print_column "Id"
      it_should_print_column "Path"
    end

  end

  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Medium::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=medium_x"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Id"
        it_should_print_column "Path"
        it_should_print_column "OS Family"
        it_should_print_column "Operating systems"
        it_should_print_column "Created at"
        it_should_print_column "Updated at"
      end
    end
  end

  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Medium::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, path, os ids", ["--name=media", "--path=http://some.path/abc/$major/Fedora/$arch/", "--operatingsystem-ids=1,2"]
      # it_should_fail_with "name missing", ["--path=http://some.path/abc/$major/Fedora/$arch/"]
      # it_should_fail_with "path missing", ["--name=media"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

    with_params ["--name=medium_x", "--path=http://some.path/", "--operatingsystem-ids=1,2"] do
      it_should_call_action :create, {'medium' => {'name' => 'medium_x', 'path' => 'http://some.path/', 'operatingsystem_ids' => [1]}}
    end
  end

  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Medium::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=media"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end

  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Medium::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=medium"]
      it_should_accept "id", ["--id=1"]
      it_should_accept "os ids", ["--id=1", "--operatingsystem-ids=1,2"]
      # it_should_fail_with "no params", []
      # it_should_fail_with "name or id missing", ["--new-name=medium_x", "--path=http://some.path/"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    with_params ["--id=1", "--new-name=medium_x", "--path=http://some.path/", "--operatingsystem-ids=1,2"] do
      it_should_call_action :update, {'id' => '1', 'name' => 'medium_x', 'medium' => {'name' => 'medium_x', 'path' => 'http://some.path/', 'operatingsystem_ids' => [1]}}
    end

  end
end
