require 'hammer_cli_foreman/compute_resource'

module HammerCLIForeman

  class Image < HammerCLIForeman::Command

    resource :images
    command_name 'image'
    desc _("View and manage compute resource's images")


    module ComputeResourceOptions

      def self.included(base)
        base.build_options

        base.validate_options do
          any(:option_compute_resource_id, :option_compute_resource_name).required
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

    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      include HammerCLIForeman::Image::ComputeResourceOptions


      output ListCommand.output_definition do
        field :architecture_id, _("Architecture Id"), Fields::Id
        field :iam_role, _("IAM role")
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end
    end


    class AvailableImagesCommand < HammerCLIForeman::ListCommand

      resource :compute_resources, :available_images
      command_name 'available'
      desc _("Show images available for addition")

      option "--compute-resource-id", "ID", " "
      option "--compute-resource", "NAME", " ", :attribute_name => :option_compute_resource_name

      include HammerCLIForeman::Image::ComputeResourceOptions

      def request_params
        params = super
        params['id'] ||= get_identifier
        params
      end

      output do
        field :name, _("Name")
        field :uuid, _("UUID")
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message _("Image created")
      failure_message _("Could not create the image")
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message _("Image updated")
      failure_message _("Could not update the image")
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message _("Image deleted")
      failure_message _("Could not delete the image")
    end

    autoload_subcommands
  end

end

