module HammerCLIForeman
  class TablePreference < HammerCLIForeman::Command
    resource :table_preferences
    command_name "table-preference"

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :columns, _("Columns"), Fields::List
      end

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _('Table preference created.')
      failure_message _('Could not create table preference')

      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _('Table preference updated.')
      failure_message _('Could not update table preference')

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      build_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _('Table preference deleted.')
      failure_message _('Could not remove table preference')

      build_options
    end

    autoload_subcommands
  end
end
