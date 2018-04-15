require 'hammer_cli_foreman/image'

module HammerCLIForeman
  class ComputeProfile < HammerCLIForeman::Command
    resource :compute_profiles

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _('Id')
        field :name, _('Name')
      end
      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do

        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)

        collection :compute_attributes, _('Compute attributes') do
          field :id, _('Id')
          field :name, _('Name')
          field nil, _('Compute Resource'), Fields::SingleReference, :key => :compute_resource
          field :vm_attrs, _('VM attributes')
        end
      end
      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _('Compute profile created.')
      failure_message _('Could not create a compute profile')
      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _('Compute profile updated.')
      failure_message _('Could not update the compute profile')
      validate_options do
        any(:option_name,:option_id).required
      end
      build_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _('Compute profile deleted.')
      failure_message _('Could not delete the Compute profile')
      validate_options do
        any(:option_name,:option_id).required
      end
      build_options
    end

    lazy_subcommand('values', _("Create update and delete Compute profile values"),
                    'HammerCLIForeman::Attribute', 'hammer_cli_foreman/attribute'
    )

    autoload_subcommands
  end
end
