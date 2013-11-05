require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class SmartProxy < HammerCLI::Apipie::Command
    resource ForemanApi::Resources::SmartProxy

    class ListCommand < HammerCLIForeman::ListCommand

      action :index

      #FIXME: search by unknown type returns 500 from the server, propper error handling should resove this
      output do
        from "smart_proxy" do
          field :id, "Id"
          field :name, "Name"
          field :url, "URL"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      action :show

      def retrieve_data
        sp = super
        sp['smart_proxy']['_features'] = sp['smart_proxy']['features'].map { |f| f['feature']['name'] }
        sp
      end

      output ListCommand.output_definition do
        from "smart_proxy" do
          field :_features,  "Features",   Fields::List
          field :created_at, "Created at", Fields::Date
          field :updated_at, "Updated at", Fields::Date
        end
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      action :create

      success_message "Smart proxy created"
      failure_message "Could not create the proxy"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      
      action :update

      success_message "Smart proxy updated"
      failure_message "Could not update the proxy"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      action :destroy

      success_message "Smart proxy deleted"
      failure_message "Could not delete the proxy"

      apipie_options
    end


    class ImportPuppetClassesCommand < HammerCLI::Apipie::WriteCommand

      action :import_puppetclasses

      command_name    "import_classes"
      success_message "Puppet classes were imported"
      failure_message "Import of puppet classes failed"

      option "--dryrun", :flag, "Do not run the import"

      apipie_options :without => [:smart_proxy_id, :dryrun]

      def request_params
        opts = super
        opts['dryrun'] = dryrun?
        opts
      end
    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'proxy', "Manipulate Foreman's smart proxies.", HammerCLIForeman::SmartProxy
