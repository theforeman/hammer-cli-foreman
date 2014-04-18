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
      end
      include HammerCLIForeman::References::Taxonomies
      include HammerCLIForeman::References::Timestamps

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

      action :import_puppetclasses

      command_name    "import-classes"
      success_message _("Puppet classes were imported")
      failure_message _("Import of puppet classes failed")

      option "--dryrun", :flag, _("Do not run the import")

      build_options :without => [:smart_proxy_id, :dryrun]

      def request_params
        opts = super
        opts['dryrun'] = option_dryrun? || false
        opts
      end
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'proxy', _("Manipulate smart proxies."), HammerCLIForeman::SmartProxy
