module HammerCLIForeman

  class Bookmark < HammerCLIForeman::Command

    resource :bookmarks

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :name, _('Name')
        field :id, _('Id')
        field :controller, _('Controller')
        field :query, _('Search Query')
        field :owner_id, _('Owner Id')
        field :owner_type, _('Owner Type')
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand

      output do
        field :name, _('Name')
        field :id, _('Id')
        field :controller, _('Controller')
        field :query, _('Search query')
        field :owner_id, _('Owner Id')
        field :owner_type, _('Owner Type')
      end

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _('Bookmark %<name>s created.')
      failure_message _('Failed to create %<name>s bookmark.')

      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message _('Bookmark %<name>s updated successfully.')
      failure_message _('Failed to update %<name>s bookmark.')

      build_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message _('Bookmark %<name>s deleted successfully.')
      failure_message _('Failed to delete %<name>s bookmark.')

      build_options
    end

    autoload_subcommands
  end
end
