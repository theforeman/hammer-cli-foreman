module HammerCLIForeman

  class Report < HammerCLIForeman::Command

    resource :reports

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :host_name, _("Host")
        field :reported_at, _("Last report"), Fields::Date
        from "status" do
          field :applied, _("Applied")
          field :restarted, _("Restarted")
          field :failed, _("Failed")
          field :failed_restarts, _("Restart Failures")
          field :skipped, _("Skipped")
          field :pending, _("Pending")
        end
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output do
        field :id, _("Id")
        field :host_name, _("Host")
        field :reported_at, _("Reported at"), Fields::Date
        label _("Report status") do
          from "status" do
            field :applied, _("Applied")
            field :restarted, _("Restarted")
            field :failed, _("Failed")
            field :failed_restarts, _("Restart Failures")
            field :skipped, _("Skipped")
            field :pending, _("Pending")
          end
        end
        label _("Report metrics") do
          from "metrics" do
            from "time" do
              field :config_retrieval, _("config_retrieval")
              field :exec, _("exec")
              field :file, _("file")
              field :package, _("package")
              field :service, _("service")
              field :user, _("user")
              field :yumrepo, _("yumrepo")
              field :filebucket, _("filebucket")
              field :cron, _("cron")
              field :total, _("total")
            end
          end
        end
        field :logs, _("Logs"), Fields::Collection do
          from :log do
            from :source do
              field :source, _("Resource")
            end
            from :message do
              field :message, _("Message")
            end
          end
        end
      end

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Report has been deleted")
      failure_message _("Could not delete the report")

      build_options
    end


    autoload_subcommands
  end

end
