module HammerCLIForeman

  class SmartProxy < HammerCLIForeman::Command

    resource :smart_proxies

    class ListCommand < HammerCLIForeman::ListCommand

      #FIXME: search by unknown type returns 500 from the server, propper error handling should resove this
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :status, _("Status")
        field :url, _("URL")
        field :_features, _( "Features"), Fields::List, :hide_blank => true
      end

      def extend_data(proxy)
        proxy['_features'] = proxy['features'].map { |f| f['name'] } if proxy['features']
        proxy
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition do
        field :version, _("Version")
        field :hosts_count, _("Host_count")
        collection :features, _("Features") do
          field :name, _('Name')
          field :version, _('Version')
        end
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Smart proxy created.")
      failure_message _("Could not create the proxy")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Smart proxy updated.")
      failure_message _("Could not update the proxy")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Smart proxy deleted.")
      failure_message _("Could not delete the proxy")

      build_options
    end

    class RefreshFeaturesCommand < HammerCLIForeman::Command

      action :refresh

      command_name    "refresh-features"
      success_message _("Smart proxy features were refreshed.")
      failure_message _("Refresh of smart proxy features failed")

      build_options
    end

    autoload_subcommands
  end

end
