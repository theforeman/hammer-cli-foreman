
module HammerCLIForeman

  class MailNotification < HammerCLIForeman::Command
    resource :mail_notifications

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :description, _("Description")
        field :subscription_type, _("Subscription type")
      end

      build_options expand: { except: %i[organizations locations] }, without: %i[organization_id location_id]
    end

    autoload_subcommands
  end
end

