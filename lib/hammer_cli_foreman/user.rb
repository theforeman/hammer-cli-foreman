module HammerCLIForeman

  class User < HammerCLIForeman::Command

    resource :users

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :login, _("Login")
        field :full_name, _("Name")
        field :mail, _("Email")
      end

      def extend_data(user)
        user["full_name"] = [user["firstname"], user["lastname"]].join(' ')
        user
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field :admin, _("Admin"), Fields::Boolean
        field :effective_admin, _("Effective admin"), Fields::Boolean
        field nil, _("Authorized by"), Fields::SingleReference, :key => :auth_source
        field :locale, _("Locale")
        field :timezone, _("Timezone")
        field :last_login_on, _("Last login"), Fields::Date
        field :description, _("Description")
        custom_field Fields::Reference, :label => _("Default organization"), :path => [:default_organization]
        custom_field Fields::Reference, :label => _("Default location"), :path => [:default_location]
        HammerCLIForeman::References.roles(self)
        HammerCLIForeman::References.usergroups(self)
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      def extend_data(user)
        user["locale"] ||= _('default') if user.has_key?("locale")
        user["timezone"] ||= _('default') if user.has_key?("timezone")
        user["full_name"] = [user["firstname"], user["lastname"]].join(' ')
        user["cached_usergroups"] = user.fetch('cached_usergroups', []) - user["usergroups"]
        user
      end

      build_options
    end

    module CommonUpdateOptions
      def self.included(base)
        base.option '--default-organization', 'DEFAULT_ORGANIZATION_NAME', _("Default organization name")
        base.option '--default-location', 'DEFAULT_LOCATION_NAME', _("Default location name")
      end

      def request_params
        params = super
        org_id = organization_id(option_default_organization)
        params['user']['default_organization_id'] ||= org_id unless org_id.nil?
        loc_id = location_id(option_default_location)
        params['user']['default_location_id'] ||= loc_id unless loc_id.nil?
        params
      end

      def organization_id(name)
        resolver.organization_id('option_name' => name) if name
      end

      def location_id(name)
        resolver.location_id('option_name' => name) if name
      end
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("User [%{login}] created")
      failure_message _("Could not create the user")

      include CommonUpdateOptions
      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("User [%{login}] updated")
      failure_message _("Could not update the user")

      include CommonUpdateOptions
      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("User [%{login}] deleted")
      failure_message _("Could not delete the user")

      build_options
    end

    HammerCLIForeman::AssociatingCommands::Role.extend_command(self)

    autoload_subcommands
  end

end


