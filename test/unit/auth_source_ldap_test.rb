require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/auth_source'

describe HammerCLIForeman::AuthSourceLdap do

  include CommandTestHelper

  context "ListCommand" do
    before :each do
      ResourceMocks.auth_source_ldap_index
    end

    let(:cmd) { HammerCLIForeman::AuthSourceLdap::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept "per page", ["--per-page=1"]
      it_should_accept "page", ["--page=2"]
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records 1
      it_should_print_column "Name"
      it_should_print_column "Id"
      it_should_print_column "LDAPS\\?"
      it_should_print_column "Port"
      it_should_print_column "Server Type"
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::AuthSourceLdap::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      #it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Id"
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::AuthSourceLdap::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "all required params", ["--name=arch", "--host=my.host"]
      # it_should_fail_with "name missing", []
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::AuthSourceLdap::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::AuthSourceLdap::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch", "--new-name=arch2"]
      it_should_accept "id", ["--id=1", "--new-name=arch2"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
      # it_should_fail_with "name or id missing", ["--new-name=arch2"] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end
end
