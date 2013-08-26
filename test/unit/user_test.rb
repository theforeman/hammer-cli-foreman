require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::User do

  extend CommandTestHelper

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource)
  end

  let(:cmd_module) { HammerCLIForeman::User }

  context "ListCommand" do

    let(:cmd) { cmd_module::ListCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.index[0].length }

      it_should_print_n_records
      it_should_print_columns ["Id", "Login", "Name", "Email"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { cmd_module::InfoCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Login", "Name", "Email"]
        it_should_print_columns ["Last login", "Created at", "Updated at"]
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { cmd_module::CreateCommand.new("") }

    context "parameters" do
      it_should_accept "all required", ["--login=login", "--mail=mail", "--password=paswd", "--auth-source-id=1"]
      it_should_accept "all required plus names", ["--login=login", "--firstname=fname", "--lastname=lname", "--mail=mail", "--password=paswd", "--auth-source-id=1"]
      it_should_fail_with "login missing", ["--firstname=fname", "--lastname=lname", "--mail=mail", "--password=paswd", "--auth-source-id=1"]
      it_should_fail_with "mail missing", ["--login=login", "--firstname=fname", "--lastname=lname", "--password=paswd", "--auth-source-id=1"]
      it_should_fail_with "password missing", ["--login=login", "--firstname=fname", "--lastname=lname", "--mail=mail", "--auth-source-id=1"]
      it_should_fail_with "auth source missing", ["--login=login", "--firstname=fname", "--lastname=lname", "--mail=mail", "--password=paswd"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { cmd_module::DeleteCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { cmd_module::UpdateCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "no params", []
    end

  end
end
