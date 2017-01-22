require 'hammer_cli_foreman/image'

module HammerCLIForeman

  class ComputeProfile < HammerCLIForeman::Command
    resource :compute_profiles

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do

        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)

        collection :compute_attributes, _("Compute attributes") do
          field :id, _('Id')
          field :name, _('Name')
          field nil, _("Compute Resource"), Fields::SingleReference, :key => :compute_resource
          field :vm_attrs, _("VM attributes")
        end
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Compute resource created")
      failure_message _("Could not create the compute resource")

      build_options

      validate_options do
        all(:option_name).required
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Compute resource updated")
      failure_message _("Could not update the compute resource")

      build_options :without => :name
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Compute resource deleted")
      failure_message _("Could not delete the compute resource")

      build_options
    end

    autoload_subcommands
  end

end


