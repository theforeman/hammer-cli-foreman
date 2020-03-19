module HammerCLIForeman

  class UserMailNotification < HammerCLIForeman::Command
    resource :mail_notifications
    command_name 'mail-notification'

    class AddMailNotificationCommand < HammerCLIForeman::CreateCommand
      command_name 'add'

      success_message _('User mail notifications was added.')
      failure_message _('Could not add user mail notification')

      build_options
    end

    class UpdateMailNotificationCommand < HammerCLIForeman::UpdateCommand
      command_name 'update'

      success_message _('User mail notifications was updated.')
      failure_message _('Could not update user mail notification')

      build_options
    end

    class RemoveMailNotificationCommand < HammerCLIForeman::DeleteCommand
      command_name 'remove'

      success_message _('User mail notification was removed.')
      failure_message _('Could not remove user mail notification')

      build_options
    end

    class ListCommand < HammerCLIForeman::ListCommand
      action :user_mail_notifications

      output do
        field :mail_notification_id, _('Id')
        field :name, _('Name')
        field :description, _('Description')
        field :interval, _('Interval')
        field :mail_query, _('Mail query')
      end

      build_options
    end

    autoload_subcommands
  end
end

