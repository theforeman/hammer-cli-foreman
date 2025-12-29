
require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli_foreman/permissions'

describe HammerCLIForeman::Permissions do
  include CommandTestHelper

  let(:cmd) { HammerCLIForeman::Permissions }

  describe 'current-permissions' do
    it "is a registered subcommand" do
      _(cmd.find_subcommand('current-permissions')).wont_be_nil
    end

    describe "configuration" do
      let(:subcommand_def) { cmd.find_subcommand('current-permissions') }
      let(:subcommand_class) { subcommand_def.subcommand_class }
      let(:subcommand_instance) { subcommand_class.new(nil, {}) }

      it "has the correct action" do
        _(subcommand_instance.action).must_equal :current_permissions
      end

      it "defines an 'Id' column" do
        fields = subcommand_instance.output_definition.fields
        field = fields.find { |f| f.label == "Id" }
        _(field).wont_be_nil
      end

      it "defines a 'Name' column" do
        fields = subcommand_instance.output_definition.fields
        field = fields.find { |f| f.label == "Name" }
        _(field).wont_be_nil
      end

      it "defines a 'Resource Type' column" do
        fields = subcommand_instance.output_definition.fields
        field = fields.find { |f| f.label == "Resource Type" }
        _(field).wont_be_nil
      end
    end
  end
end
