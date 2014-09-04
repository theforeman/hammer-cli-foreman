module HammerCLIForeman

  class AuthSourceLdap < HammerCLIForeman::Command

    resource :auth_source_ldaps

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id                , _("Id")
        field :name              , _("Name")
        field :tls               , _('LDAPS?')
        field :port              , _('Port')
        field :type              , _("Server Type")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :account           , _('Account Username')
        field :base_dn           , _('Base DN')
        field :ldap_filter       , _('LDAP filter')
        field :onthefly_register , _('Automatically Create Accounts?')
        field :attr_login        , _('Login Name Attribute')
        field :attr_firstname    , _('First Name Attribute')
        field :attr_lastname     , _('Last Name Attribute')
        field :attr_mail         , _('Email Address Attribute')
        field :attr_photo        , _('Photo Attribute')
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Auth source created")
      failure_message _("Could not create the Auth Source")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Auth source deleted")
      failure_message _("Could not delete the Auth Source")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Auth source updated")
      failure_message _("Could not update the Auth Source")

      build_options
    end

    autoload_subcommands
  end

end


