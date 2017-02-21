module HammerCLIForeman

  class SmartProxy < HammerCLIForeman::Command

    resource :smart_proxies

    class ListCommand < HammerCLIForeman::ListCommand

      #FIXME: search by unknown type returns 500 from the server, propper error handling should resove this
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :url, _("URL")
        field :_features, _( "Features"), Fields::List, :width => 25, :hide_blank => true
      end

      def extend_data(proxy)
        proxy['_features'] = proxy['features'].map { |f| f['name'] } if proxy['features']
        proxy
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        collection :features,  _("Features"), :numbered => false do
          custom_field Fields::Reference
        end
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Smart proxy created")
      failure_message _("Could not create the proxy")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Smart proxy updated")
      failure_message _("Could not update the proxy")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Smart proxy deleted")
      failure_message _("Could not delete the proxy")

      build_options
    end


    class ImportPuppetClassesCommand < HammerCLIForeman::Command
      include HammerCLIForemanTasks::Async

      action :import_puppetclasses

      command_name    "import-classes"
      success_message _("Puppet classes import succeeded")
      failure_message _("Import of puppet classes failed")

      option "--dryrun", :flag, _("Do not run the import")
      option "--background", :flag, _("Run import on background")

      build_options do |o|
        o.without(:smart_proxy_id, :dryrun)
        o.without(:smart_proxy_id, :background)
        o.expand.except(:smart_proxies)
      end

      def request_params
        opts = super
        opts['dryrun'] = option_dryrun? || false
        opts['background'] = option_background? || false
        opts
      end
    end


    class RefreshFeaturesCommand < HammerCLIForeman::Command

      action :refresh

      command_name    "refresh-features"
      success_message _("Smart proxy features were refreshed")
      failure_message _("Refresh of smart proxy features failed")

      build_options
    end

    autoload_subcommands
  end

end


