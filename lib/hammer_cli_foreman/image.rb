
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
        field nil, _("Operating System"), Fields::SingleReference, :key => :operatingsystem
        field :username, _("Username")
        field :uuid, _("UUID")
      end

    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      include HammerCLIForeman::Image::ComputeResourceOptions


      output ListCommand.output_definition do
        field nil, _("Architecture"), Fields::SingleReference, :key => :architecture
        field :iam_role, _("IAM role")
        HammerCLIForeman::References.timestamps(self)
      end
    end


    class AvailableImagesCommand < HammerCLIForeman::ListCommand

      resource :compute_resources, :available_images
      command_name 'available'
      desc _("Show images available for addition")

      option '--compute-resource-id', 'ID', '',
        :attribute_name => HammerCLI.option_accessor_name('id')
      option '--compute-resource', 'NAME', _('Compute resource name'),
        :attribute_name => HammerCLI.option_accessor_name('name')

      output do
        field :name, _("Name")
        field :uuid, _("UUID")
      end

      build_options :expand => { :primary => false }, :without => :id
    end

    class CreateCommand < HammerCLIForeman::CreateCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message _("Image created.")
      failure_message _("Could not create the image")
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message _("Image updated.")
      failure_message _("Could not update the image")
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      include HammerCLIForeman::Image::ComputeResourceOptions

      success_message _("Image deleted.")
      failure_message _("Could not delete the image")
    end

    autoload_subcommands
  end

end
