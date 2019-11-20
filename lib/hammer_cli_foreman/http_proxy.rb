module HammerCLIForeman

    class HttpProxy < HammerCLIForeman::Command

      resource :http_proxies

      class ListCommand < HammerCLIForeman::ListCommand

        output do
          field :id, _("Id")
          field :name, _("Name")
        end

        build_options
      end

      class InfoCommand < HammerCLIForeman::InfoCommand
        output ListCommand.output_definition do
          field :username, _("Username")
          field :url, _("URL")
        end

        build_options
      end

      class CreateCommand < HammerCLIForeman::CreateCommand
        success_message _("Http proxy created.")
        failure_message _("Could not create the http proxy")

        build_options
      end

      class DeleteCommand < HammerCLIForeman::DeleteCommand
        success_message _("Http proxy deleted.")
        failure_message _("Could not delete the http proxy")

        build_options
      end

      class UpdateCommand < HammerCLIForeman::UpdateCommand
        success_message _("Http proxy updated.")
        failure_message _("Could not update the http proxy")

        build_options
      end

      autoload_subcommands
    end
end