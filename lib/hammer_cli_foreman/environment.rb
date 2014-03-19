require 'hammer_cli'
require 'hammer_cli_foreman/smart_class_parameter'


module HammerCLIForeman

  class Environment < HammerCLIForeman::Command

    resource :environments

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("Environment created")
      failure_message _("Could not create the environment")

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message _("Environment updated")
      failure_message _("Could not update the environment")

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _("Environment deleted")
      failure_message _("Could not delete the environment")

      apipie_options
    end

    class SCParamsCommand < HammerCLIForeman::SmartClassParametersList

      apipie_options :without => [:host_id, :hostgroup_id, :puppetclass_id, :environment_id]
      option ['--id', '--name'], 'ENVIRONMENT_ID', _('environment id/name'),
            :required => true, :attribute_name => :environment_id
    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'environment', "Manipulate environments.", HammerCLIForeman::Environment
