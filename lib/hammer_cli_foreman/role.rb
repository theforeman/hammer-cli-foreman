module HammerCLIForeman

  class Role < HammerCLIForeman::Command

    resource :roles

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options
    end


    class FiltersCommand < HammerCLIForeman::ListCommand
      command_name "filters"
      resource :filters, :index

      option "--id", "ID", _("User role id")

      output HammerCLIForeman::Filter::ListCommand.output_definition

      def request_params
        role_id = get_resource_id(HammerCLIForeman.foreman_resource(:roles))

        params = super
        params[:search] = "role_id = \"#{role_id}\""
        params
      end

      def extend_data(filter)
        filter['resource_type'] ||= _("(Miscellaneous)")
        filter['search'] ||= _("none")
        filter['permissions'] = filter.fetch('permissions', []).collect{|p| p["name"]}
        filter
      end

      build_options do |o|
        o.expand.primary(:roles)
        o.without(:search)
      end
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("User role [%<name>s] created")
      failure_message _("Could not create the user role")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("User role [%<name>s] updated")
      failure_message _("Could not update the user role")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("User role [%<name>s] deleted")
      failure_message _("Could not delete the user roles")

      build_options
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'role', _("Manage user roles."), HammerCLIForeman::Role

