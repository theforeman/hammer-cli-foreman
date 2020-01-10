module HammerCLIForeman
  class AuthSourceExternal < HammerCLIForeman::Command
    resource :auth_source_externals
    command_name 'external'
    desc _('Manage external auth sources')

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
      end

      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      desc _('Update organization and location for Auth Source')

      success_message _('Successfully updated the %{name} external auth source.')
      failure_message _('Failed to update %{name} external auth source')

      build_options
    end

    autoload_subcommands
  end
end
