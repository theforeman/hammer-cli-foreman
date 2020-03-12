
module HammerCLIForeman

  class MailNotification < HammerCLIForeman::Command
    resource :mail_notifications

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :description, _("Description")
        field :subscription_type, _("Subscription type")
      end

      build_options
    end

    autoload_subcommands
  end
end

