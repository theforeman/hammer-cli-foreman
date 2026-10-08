require 'hammer_cli_foreman/commands'

module HammerCLIForeman
  class Permissions < HammerCLIForeman::Command
    resource :permissions

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :resource_type, _("Resource Type")
      end
      build_options
    end

    class CurrentPermissions < HammerCLIForeman::ListCommand
      command_name "current-permissions"
      action :current_permissions

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :resource_type, _("Resource Type")
      end

      build_options
    end

    autoload_subcommands
  end
end
