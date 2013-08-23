require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Template do

  extend CommandTestHelper

  let(:template_hash) {
    {
      "config_template" => {
        "template_kind" => {}
      }
    }
  }

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource)
    cmd.class.resource.stubs(:index).returns([[], nil])
    cmd.class.resource.stubs(:show).returns([template_hash, nil])

    File.stubs(:read).returns("")
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Template::ListCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.index[0].length }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "Type"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Template::InfoCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      let(:with_params) { ["--id=1"] }
      it_should_print_n_records 1
      it_should_print_columns ["Id", "Name", "Type", "OS ids"]
    end

  end


  context "ListKindsCommand" do

    let(:cmd) { HammerCLIForeman::Template::ListKindsCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
    end

  end


  context "DumpCommand" do

    let(:cmd) { HammerCLIForeman::Template::DumpCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "id missing", []
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Template::CreateCommand.new("") }

    before :each do
      cmd.stubs(:template_kind_id).returns(1)
    end

    context "parameters" do
      it_should_accept "name, file, type, audit comment, os ids", ["--name=tpl", "--file=~/tpl.sh", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      it_should_fail_with "name missing", ["--file=~/tpl.sh", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      it_should_fail_with "type missing", ["--name=tpl", "--file=~/tpl.sh", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      it_should_fail_with "file missing", ["--name=tpl", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Template::UpdateCommand.new("") }

    before :each do
      cmd.stubs(:template_kind_id).returns(1)
    end

    context "parameters" do
      it_should_accept "id, name, file, type, audit comment, os ids", ["--id=83", "--name=tpl", "--file=~/tpl.sh", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      it_should_fail_with "id missing", ["--name=tpl", "--file=~/tpl.sh", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Template::DeleteCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "id missing", []
    end

  end

end
