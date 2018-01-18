require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'test_output_adapter')

require 'hammer_cli_foreman/compute_profile'

describe HammerCLIForeman::ComputeProfile do

  include CommandTestHelper

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::ComputeProfile::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns ["Name", "Id"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::ComputeProfile::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Name", "Id", "Compute attributes"]
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::ComputeProfile::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::ComputeProfile::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::ComputeProfile::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch", "--new-name=arch2"]
      it_should_accept "id", ["--id=1", "--new-name=arch2"]
    end

  end


end
