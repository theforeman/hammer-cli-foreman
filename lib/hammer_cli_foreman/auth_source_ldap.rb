module HammerCLIForeman
  class AuthSourceLdap < HammerCLIForeman::Command
    resource :auth_source_ldaps
    command_name 'ldap'
    desc _('Manage LDAP auth sources')

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _('Id')
        field :name, _('Name')
        field :host, _('Server')
        field :port, _('Port')
        field :tls, _('LDAPS?'), Fields::Boolean
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output do
        label _('Server') do
          field :id, _('Id')
          field :name, _('Name')
          field :host, _('Server')
          field :tls, _('LDAPS'), Fields::Boolean
          field :port, _('Port')
          field :server_type, _('Server Type')
        end
        label _('Account') do
          field :account, _('Account Username')
          field :base_dn, _('Base DN')
          field :groups_base, _('Groups base DN')
          field :use_netgroups, _('Use Netgroups'), Fields::Boolean
          field :ldap_filter, _('LDAP filter')
          field :onthefly_register, _('Automatically Create Accounts?'), Fields::Boolean
          field :usergroup_sync, _('Usergroup sync'), Fields::Boolean
        end
        label _('Attribute mappings') do
          field :attr_login, _('Login Name Attribute')
          field :attr_firstname, _('First Name Attribute')
          field :attr_lastname, _('Last Name Attribute')
          field :attr_mail, _('Email Address Attribute')
          field :attr_photo, _('Photo Attribute')
        end
        HammerCLIForeman::References.taxonomies(self)
      end

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _('Auth source [%{name}] created.')
      failure_message _('Could not create the Auth Source')

      build_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _('Auth source [%{name}] deleted.')
      failure_message _('Could not delete the Auth Source')

      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _('Auth source [%{name}] updated.')
      failure_message _('Could not update the Auth Source')

      build_options
    end

    autoload_subcommands
  end
end
