# frozen_string_literal: true

module HammerCLIForeman
  class Bookmark < HammerCLIForeman::Command
    resource :bookmarks

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _('Id')
        field :name, _('Name')
        field :controller, _('Controller')
        field :query, _('Search Query')
        field :public, _('Public')
        field :owner_id, _('Owner Id')
        field :owner_type, _('Owner Type')
      end

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _('Bookmark %<name>s created.')
      failure_message _('Failed to create %<name>s bookmark')

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _('Bookmark %<name>s updated successfully.')
      failure_message _('Failed to update %<name>s bookmark')

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _('Bookmark deleted successfully.')
      failure_message _('Failed to delete bookmark')

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end

    autoload_subcommands
  end
end
