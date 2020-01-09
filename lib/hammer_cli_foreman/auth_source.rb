require 'hammer_cli_foreman/auth_source_ldap'
require 'hammer_cli_foreman/auth_source_external'

module HammerCLIForeman
  class AuthSource < HammerCLIForeman::Command
    resource :auth_sources
    subcommand 'ldap', HammerCLIForeman::AuthSourceLdap.desc, HammerCLIForeman::AuthSourceLdap
    subcommand 'external', HammerCLIForeman::AuthSourceExternal.desc, HammerCLIForeman::AuthSourceExternal

    class ListCommand < HammerCLIForeman::ListCommand
      desc _('List all auth sources')

      output do
        field :id, _('Id')
        field :name, _('Name')
        field :type, _('Type of auth source')
      end

      build_options
    end

    autoload_subcommands
  end
end
