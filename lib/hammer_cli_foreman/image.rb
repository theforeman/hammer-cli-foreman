require 'hammer_cli_foreman/compute_resource'

module HammerCLIForeman

  class Image < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Image
    command_name 'image'
    desc _("View and manage compute resource's images")


    module ComputeResourceOptions

      def self.included(base)
        base.option "--compute-resource", "COMPUTE_RESOURCE_NAME", _("Compute resource's name")
        base.option "--compute-resource-id", "COMPUTE_RESOURCE_ID", _("Compute resource's id")
        base.apipie_options :without => [:compute_resource_id, :id]

        base.validate_options do
          any(:option_compute_resource_id, :option_compute_resource).required
        end
      end

    end


    class ListCommand < HammerCLIForeman::ListCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :operatingsystem_id, _("Operating System Id"), Fields::Id
        field :username, _("Username")
        field :uuid, _("UUID")
      end

      def request_params
        params = super
        params['compute_resource_id'] = option_compute_resource_id || option_compute_resource
        params
      end

    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      identifiers :id
      include HammerCLIForeman::Image::ComputeResourceOptions


      output ListCommand.output_definition do
        field :architecture_id, _("Architecture Id"), Fields::Id
        field :iam_role, _("IAM role")
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      def request_params
        params = super
        params['compute_resource_id'] = option_compute_resource_id || option_compute_resource
        params
      end

    end


    class AvailableImagesCommand < HammerCLIForeman::ListCommand

      resource ForemanApi::Resources::ComputeResource, _("available_images")
      command_name 'available'
      desc _("Show images available for addition")

      include HammerCLIForeman::Image::ComputeResourceOptions

      output do
        field :name, _("Name")
        field :uuid, _("UUID")
      end

      def request_params
        params = super
        params['id'] = option_compute_resource_id || option_compute_resource
        params
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message _("Image created")
      failure_message _("Could not create the image")

      def request_params
        params = super
        params['compute_resource_id'] = option_compute_resource_id || option_compute_resource
        params
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      identifiers :id
      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message _("Image updated")
      failure_message _("Could not update the image")

      def request_params
        params = super
        params['compute_resource_id'] = option_compute_resource_id || option_compute_resource
        params
      end

    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id
      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message _("Image deleted")
      failure_message _("Could not delete the image")

      def request_params
        params = super
        params['compute_resource_id'] = option_compute_resource_id || option_compute_resource
        params
      end

    end

    autoload_subcommands
  end

end

