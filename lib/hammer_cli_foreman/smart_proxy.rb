require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class SmartProxy < HammerCLI::AbstractCommand
    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::SmartProxy, "index"

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

      resource ForemanApi::Resources::SmartProxy, "show"

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

      success_message "Smart proxy created"
      failure_message "Could not create the proxy"
      resource ForemanApi::Resources::SmartProxy, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Smart proxy updated"
      failure_message "Could not update the proxy"
      resource ForemanApi::Resources::SmartProxy, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Smart proxy deleted"
      failure_message "Could not delete the proxy"
      resource ForemanApi::Resources::SmartProxy, "destroy"

      apipie_options
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'proxy', "Manipulate Foreman's smart proxies.", HammerCLIForeman::SmartProxy
