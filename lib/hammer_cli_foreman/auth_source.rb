require 'hammer_cli_foreman/auth_source_ldap'

module HammerCLIForeman

  class AuthSource < HammerCLIForeman::Command
    resource :auth_sources
    subcommand 'ldap', HammerCLIForeman::AuthSourceLdap.desc, HammerCLIForeman::AuthSourceLdap

    class ListCommand < HammerCLIForeman::ListCommand
      desc _('List all auth sources')

      output do
        field :id, _('Id')
        field :name, _('Name')
        field :type, _('Type of auth source')
      end

      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      desc _('Update organization and location for Auth Source')
      resource :auth_source_externals
  
      success_message _('Taxonomy updated.')
      failure_message _('Taxonomy not changed. Please check if appropriate auth source exists')

      build_options
    end

    autoload_subcommands
  end
end
