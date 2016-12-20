module HammerCLIForeman

  class Filter < HammerCLIForeman::Command

    resource :filters

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :resource_type, _("Resource type")
        field :search, _("Search")
        field :unlimited?, _("Unlimited?"), Fields::Boolean
        field :override?, _("Override?"), Fields::Boolean
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
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      def extend_data(filter)
        filter['resource_type'] ||= _("(Miscellaneous)")
        filter['search'] ||= _("none")
        filter['permissions'] = filter.fetch('permissions', []).collect{|p| p["name"]}
        filter
      end

      build_options
    end


    module TaxonomyCheck
      def taxonomy_options?
        option_location_names || option_location_ids || option_organization_names || option_organization_ids
      end

      def signal_override_usage_error
        signal_usage_error _('Organizations and locations can be set only for overriding filters')
      end

      def self.included(base)
        base.extend_help do |h|
          h.section('Overriding organizations and locations') do
            override_condition = "--override=true"
            org_opts = '--organization[s|-ids]'
            loc_opts = '--location[s|-ids]'

            h.text(_("Filters inherit organizations and locations from its role by default. This behavior can be changed by setting %{condition}\n"+
              "Therefore options %{org_opts} and %{loc_opts} are applicable only when the override flag is set.") % {
              :org_opts => org_opts,
              :loc_opts => loc_opts,
              :condition => override_condition
            })
          end
        end
      end
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include TaxonomyCheck

      success_message _("Permission filter for [%<resource_type>s] created")
      failure_message _("Could not create the permission filter")

      def execute
        signal_override_usage_error if !option_override && taxonomy_options?
        super
      end

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include TaxonomyCheck

      success_message _("Permission filter for [%<resource_type>s] updated")
      failure_message _("Could not update the permission filter")

      def request_params
        params = super
        if override?
          # Clear taxonomies in case the filter is switching override from true to false
          params['filter']['location_ids'] = []
          params['filter']['organization_ids'] = []
        end
        params
      end

      def execute
        signal_override_usage_error if !override? && taxonomy_options?
        super
      end

      def override?
        option_override || filter['override?']
      end

      def filter
        @filter ||= HammerCLIForeman.foreman_resource!(:filters).action(:show).call({ :id => option_id }, request_headers, request_options)
      end

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Permission filter deleted")
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



