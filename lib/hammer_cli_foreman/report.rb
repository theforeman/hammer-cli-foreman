require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class Report < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Report

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        from "report" do
          field :id, "Id"
          field :host_name, "Host"
          field :reported_at, "Last report", HammerCLI::Output::Fields::Date
          from "status" do
            field :applied, "Applied"
            field :restarted, "Restarted"
            field :failed, "Failed"
            field :failed_restarts, "Restart Failures"
            field :skipped, "Skipped"
            field :pending, "Pending"
          end
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      identifiers :id

      output do
        from "report" do
          field :id, "Id"
          field :host_name, "Host"
          field :reported_at, "Reported at", HammerCLI::Output::Fields::Date
          label "Report status" do
            from "status" do
              field :applied, "Applied"
              field :restarted, "Restarted"
              field :failed, "Failed"
              field :failed_restarts, "Restart Failures"
              field :skipped, "Skipped"
              field :pending, "Pending"
            end
          end
          label "Report metrics" do
            from "metrics" do
              from "time" do
                field :config_retrieval, "config_retrieval"
                field :exec, "exec"
                field :file, "file"
                field :package, "package"
                field :service, "service"
                field :user, "user"
                field :yumrepo, "yumrepo"
                field :filebucket, "filebucket"
                field :cron, "cron"
                field :total, "total"
              end
            end
          end
          field :logs, "Logs", HammerCLI::Output::Fields::Collection do
            from :log do
              from :source do
                field :source, "Resource"
              end
              from :message do
                field :message, "Message"
              end
            end
          end
        end
      end

    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      identifiers :id
      success_message "Report has been deleted"
      failure_message "Could not delete the report"
    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'report', "Browse and read reports.", HammerCLIForeman::Report

