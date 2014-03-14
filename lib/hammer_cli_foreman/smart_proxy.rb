module HammerCLIForeman

  class SmartProxy < HammerCLI::Apipie::Command
    resource ForemanApi::Resources::SmartProxy

    class ListCommand < HammerCLIForeman::ListCommand

      action :index

      #FIXME: search by unknown type returns 500 from the server, propper error handling should resove this
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :url, _("URL")
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      action :show

      output ListCommand.output_definition do
        field :_features, _( "Features"),   Fields::List
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end

      def extend_data(proxy)
        proxy['_features'] = proxy['features'].map { |f| f['name'] }
        proxy
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      action :create

      success_message _("Smart proxy created")
      failure_message _("Could not create the proxy")

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      action :update

      success_message _("Smart proxy updated")
      failure_message _("Could not update the proxy")

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      action :destroy

      success_message _("Smart proxy deleted")
      failure_message _("Could not delete the proxy")

      apipie_options
    end


    class ImportPuppetClassesCommand < HammerCLIForeman::WriteCommand

      action :import_puppetclasses

      command_name    "import_classes"
      success_message _("Puppet classes were imported")
      failure_message _("Import of puppet classes failed")

      option "--dryrun", :flag, _("Do not run the import")

      apipie_options :without => [:smart_proxy_id, :dryrun]

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
