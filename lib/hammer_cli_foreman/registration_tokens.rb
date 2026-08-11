module HammerCLIForeman
  class RegistrationTokens < HammerCLIForeman::Command
    resource :registration_tokens
    command_name 'registration-tokens'
    desc _('Manage registration tokens')

    class InvalidateMultipleCommand < HammerCLIForeman::DeleteCommand
      action :invalidate_jwt_tokens
      command_name 'invalidate-multiple'
      success_message _('Successfully invalidated registration tokens for %{users}.')
      failure_message _('Could not invalidate registration tokens')
      option "--search", "SEARCH",
       _("Search query that selects users for which registration tokens will be invalidated. Search query example: id ^ (2, 4, 6)"), :required => true

      build_options
    end

    class InvalidateCommand < HammerCLIForeman::DeleteCommand
      action :invalidate_jwt
      command_name 'invalidate'
      success_message _('Successfully invalidated registration tokens for %{user}.')
      failure_message _('Could not invalidate registration tokens')

      build_options
    end

    autoload_subcommands
  end
end
