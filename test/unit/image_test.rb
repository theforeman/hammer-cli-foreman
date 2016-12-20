require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'test_output_adapter')

require 'hammer_cli_foreman/image'

describe HammerCLIForeman::Image do


  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:images, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Image::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "compute resource name", ["--compute-resource=cr"]
      it_should_accept "compute resource id", ["--compute-resource-id=1"]
      #it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index, :compute_resource_id=>1)) }

      with_params ["--compute-resource-id=1"] do
        it_should_print_n_records
        it_should_print_column "Id"
        it_should_print_column "Name"
        it_should_print_column "Operating System"
        it_should_print_column "Username"
        it_should_print_column "UUID"
      end
    end
  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Image::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "compute resource name and image's uuid", ["--compute-resource=cr", "--id=1"]
      it_should_accept "compute resource id and image's uuid", ["--compute-resource-id=1", "--id=1"]
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index).length }

      with_params ["--compute-resource-id=1", "--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Id"
        it_should_print_column "Name"
        it_should_print_column "Operating System"
        it_should_print_column "Architecture"
        it_should_print_column "Username"
        it_should_print_column "UUID"
        it_should_print_column "IAM role"
      end
    end
  end

  context "AvailableImagesCommand" do

    let(:cmd) { HammerCLIForeman::Image::AvailableImagesCommand.new("", ctx) }

    before :each do

      ResourceMocks.compute_resources_available_images
    end

    context "parameters" do
      it_should_accept "compute resource name", ["--compute-resource=cr"]
      it_should_accept "compute resource id", ["--compute-resource-id=1"]
    end

    context "output" do
      with_params ["--compute-resource-id=1"] do
        it_should_print_column "Name"
        it_should_print_column "UUID"
      end
    end
  end

  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Image::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "all required params", ["--name=img", "--operatingsystem-id=1", "--architecture-id=1", "--username=root", "--uuid=aabbcc123", "--compute-resource-id=1"]
      it_should_accept "all required params and resource's name", ["--name=img", "--operatingsystem-id=1", "--architecture-id=1", "--username=root", "--uuid=aabbcc123", "--compute-resource=ec2"]
      # it_should_fail_with "name missing", ["--operatingsystem-id=1", "architecture-id=1", "--username=root", "--uuid=aabbcc123", "--compute-resource-id=1"]
      # it_should_fail_with "os id missing", ["--name=img", "--operatingsystem-id=1", "architecture-id=1", "--username=root", "--uuid=aabbcc123", "--compute-resource-id=1"]
      # it_should_fail_with "architecture id missing", ["--name=img", "--operatingsystem-id=1", "--username=root", "--uuid=aabbcc123", "--compute-resource-id=1"]
      # it_should_fail_with "username id missing", ["--name=img", "--operatingsystem-id=1", "architecture-id=1", "--uuid=aabbcc123", "--compute-resource-id=1"]
      # it_should_fail_with "uuid missing", ["--name=img", "--operatingsystem-id=1", "architecture-id=1", "--username=root", "--compute-resource-id=1"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Image::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id and resource's id", ["--id=1", "--compute-resource-id=1"]
      it_should_accept "id and resource's name", ["--id=1", "--compute-resource=ec2"]
      # it_should_fail_with "id missing", ["--compute-resource-id=1"]
      # it_should_fail_with "resource's id or name missing", ["--id=1"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Image::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id and resource's id", ["--id=1", "--compute-resource-id=1"]
      it_should_accept "id and resource's name", ["--id=1", "--compute-resource=ec2"]
      it_should_accept "all available params", ["--id=1", "--name=img", "--operatingsystem-id=1", "--architecture-id=1", "--username=root", "--uuid=aabbcc123", "--compute-resource-id=1"]
      # it_should_fail_with "id missing", ["--compute-resource-id=1"]
      # it_should_fail_with "resource's id or name missing", ["--id=1"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

end
