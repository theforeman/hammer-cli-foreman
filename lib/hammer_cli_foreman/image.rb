require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/compute_resource'

module HammerCLIForeman

  class Image < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Image
    command_name 'image'
    desc "View and manage compute resource's images"


    module ComputeResourceOptions

      def self.included(base)
        base.option "--compute-resource", "COMPUTE_RESOURCE_NAME", "Compute resource's name"
        base.option "--compute-resource-id", "COMPUTE_RESOURCE_ID", "Compute resource's id"
        base.apipie_options :without => [:compute_resource_id, :id]

        base.validate_options do
          any(:compute_resource_id, :compute_resource).required
        end
      end

    end


    class ListCommand < HammerCLIForeman::ListCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      output do
        field :id, "Id"
        field :name, "Name"
        field :operatingsystem_id, "Operating System Id", Fields::Id
        field :username, "Username"
        field :uuid, "UUID"
      end

      def request_params
        params = super
        params['compute_resource_id'] = compute_resource_id || compute_resource
        params
      end

    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      identifiers :id
      include HammerCLIForeman::Image::ComputeResourceOptions


      output ListCommand.output_definition do
        field :architecture_id, "Architecture Id", Fields::Id
        field :iam_role, "IAM role"
        field :created_at, "Created at", Fields::Date
        field :updated_at, "Updated at", Fields::Date
      end

      def request_params
        params = super
        params['compute_resource_id'] = compute_resource_id || compute_resource
        params
      end

    end


    class AvailableImagesCommand < HammerCLIForeman::ListCommand

      resource ForemanApi::Resources::ComputeResource, "available_images"
      command_name 'available'
      desc "Show images available for addition"

      include HammerCLIForeman::Image::ComputeResourceOptions

      output do
        field :name, "Name"
        field :uuid, "UUID"
      end

      def request_params
        params = super
        params['id'] = compute_resource_id || compute_resource
        params
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message "Image created"
      failure_message "Could not create the image"

      def request_params
        params = super
        params['compute_resource_id'] = compute_resource_id || compute_resource
        params
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      identifiers :id
      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message "Image updated"
      failure_message "Could not update the image"

      def request_params
        params = super
        params['compute_resource_id'] = compute_resource_id || compute_resource
        params
      end

    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id
      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message "Image deleted"
      failure_message "Could not delete the image"

      def request_params
        params = super
        params['compute_resource_id'] = compute_resource_id || compute_resource
        params
      end

    end

    autoload_subcommands
  end

end

