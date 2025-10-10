module HammerCLIForeman

  class Filter < HammerCLIForeman::Command

    resource :filters

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :resource_type, _("Resource type")
        field :search, _("Search")
        field :role, _("Role"), Fields::Reference
        field :permissions, _("Permissions"), Fields::List
      end

      def extend_data(filter)
        filter['resource_type'] ||= _("(Miscellaneous)")
        filter['search'] ||= _("none")
        filter['permissions'] = filter.fetch('permissions', []).collect{|p| p["name"]}
        filter
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        HammerCLIForeman::References.timestamps(self)
        from :role do
          collection :locations, _("Locations"), numbered: false, hide_blank: true do
            custom_field Fields::Reference, name_key: :title
          end
          collection :organizations, _("Organizations"), numbered: false, hide_blank: true do
            custom_field Fields::Reference, name_key: :title
          end
        end
      end

      def extend_data(filter)
        filter['resource_type'] ||= _("(Miscellaneous)")
        filter['search'] ||= _("none")
        filter['permissions'] = filter.fetch('permissions', []).collect{|p| p["name"]}
        filter
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Permission filter for [%<resource_type_label>s] created.")
      failure_message _("Could not create the permission filter")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Permission filter for [%<resource_type_label>s] updated.")
      failure_message _("Could not update the permission filter")

      def filter
        @filter ||= HammerCLIForeman.foreman_resource!(:filters).action(:show).call({ :id => get_identifier }, request_headers, request_options)
      end

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Permission filter deleted.")
      failure_message _("Could not delete the permission filter")

      build_options
    end


    class AvailablePermissionsCommand < HammerCLIForeman::ListCommand
      resource :permissions, :index
      command_name 'available-permissions'

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :resource_type, _("Resource")
      end

      def extend_data(filter)
        filter['resource_type'] ||= _("(Miscellaneous)")
        filter
      end

      build_options
    end

    class AvailableResourcesCommand < HammerCLIForeman::ListCommand
      resource :permissions, :resource_types
      command_name 'available-resources'

      output do
        field :name, _("Name")
      end

      build_options
    end

    autoload_subcommands
  end
end
