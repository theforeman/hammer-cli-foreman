require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/template'

describe HammerCLIForeman::Template do

  include CommandTestHelper

  let(:template_hash) {
    {
      "config_template" => {
        "template_kind" => {}
      }
    }
  }

  before :each do
    cmd.stubs(:get_identifier).returns(1)
    File.stubs(:read).returns("")
  end

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:config_templates, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Template::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "Type"]

      it "should print template without kind set" do
        template_wo_kind = {
          "config_template" => {
            :id => 1, :name => "PXE"
          }
        }
        ResourceMocks.mock_action_call(:config_templates, :show, template_wo_kind)
        cmd.run([]).must_equal 0
      end
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Template::InfoCommand.new("", ctx) }

    context "parameters" do
      before(:each) do
        template = {
          'config_template' => {
            'id' => 1, 'name' => 'PXE', 'type' => 'something',
            'operatingsystems' => [ { 'id' => 1 }, { 'id' => 3 }, { 'id' =>4 } ]
          }
        }
        ResourceMocks.mock_action_call(:config_templates, :show, template)
      end

      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        before(:each) do
          template = {
            'config_template' => {
              'id' => 1, 'name' => 'PXE', 'type' => 'something',
              'operatingsystems' => [ { 'id' => 1 }, { 'id' => 3 }, { 'id' =>4 } ]
            }
          }
          ResourceMocks.mock_action_call(:config_templates, :show, template)
        end

        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Type", "Operating systems"]
      end
    end

  end


  context "ListKindsCommand" do
    before do
      ResourceMocks.mock_action_call(:template_kinds, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Template::ListKindsCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
    end

  end


  context "DumpCommand" do

    let(:cmd) { HammerCLIForeman::Template::DumpCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Template::CreateCommand.new("", ctx) }

    before :each do
      cmd.stubs(:option_template_kind_id).returns(1)
    end

    context "parameters" do
      it_should_accept "name, file, type, audit comment, os ids", ["--name=tpl", "--file=~/tpl.sh", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      # it_should_fail_with "name missing", ["--file=~/tpl.sh", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      # it_should_fail_with "type missing", ["--name=tpl", "--file=~/tpl.sh", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      # it_should_fail_with "file missing", ["--name=tpl", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Template::UpdateCommand.new("", ctx) }

    before :each do
      cmd.stubs(:option_template_kind_id).returns(1)
    end

    context "parameters" do
      it_should_accept "id, name, file, type, audit comment, os ids", ["--id=83", "--name=tpl", "--file=~/tpl.sh", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      # it_should_fail_with "id missing", ["--name=tpl", "--file=~/tpl.sh", "--type=snippet", "--audit-comment=fix", "--operatingsystem-ids=1,2,3"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Template::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

end
