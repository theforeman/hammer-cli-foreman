require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/user'

describe HammerCLIForeman::User do

  include CommandTestHelper

  let(:cmd_module) { HammerCLIForeman::User }

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:users, :index, [])
    end

    let(:cmd) { cmd_module::ListCommand.new("", ctx ) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }
      it_should_print_n_records
      it_should_print_columns ["Id", "Login", "Name", "Email"]
    end

  end


  context "InfoCommand" do
    before do
      ResourceMocks.users_show
    end

    let(:cmd) { cmd_module::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "login", ["--login=admin"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Login", "Name", "Email", "Admin", "Effective admin"]
        it_should_print_columns ["Last login", "Created at", "Updated at"]
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { cmd_module::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "all required", ["--login=login", "--mail=mail", "--password=paswd", "--auth-source-id=1"]
      it_should_accept "all required plus names", ["--login=login", "--firstname=fname", "--lastname=lname", "--mail=mail", "--password=paswd", "--auth-source-id=1"]
      # it_should_fail_with "login missing", ["--firstname=fname", "--lastname=lname", "--mail=mail", "--password=paswd", "--auth-source-id=1"]
      # it_should_fail_with "mail missing", ["--login=login", "--firstname=fname", "--lastname=lname", "--password=paswd", "--auth-source-id=1"]
      # it_should_fail_with "password missing", ["--login=login", "--firstname=fname", "--lastname=lname", "--mail=mail", "--auth-source-id=1"]
      # it_should_fail_with "auth source missing", ["--login=login", "--firstname=fname", "--lastname=lname", "--mail=mail", "--password=paswd"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  context "DeleteCommand" do

    let(:cmd) { cmd_module::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "login", ["--login=admin"]
      # it_should_fail_with "id and login missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "UpdateCommand" do

    let(:cmd) { cmd_module::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "login", ["--login=admin"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end
end
