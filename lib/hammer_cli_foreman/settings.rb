
module HammerCLIForeman

  class Settings < HammerCLIForeman::Command

    resource :settings

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _('Id'), Fields::Id
        field :name, _('Name')
        field :full_name, _('Full name')
        field :value, _('Value')
        field :description, _('Description')
      end

      def extend_data(data)
        data['value'] = data['value'].to_s
        data
      end

      build_options
    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      command_name 'set'

      success_message _("Setting [%{name}] updated to [%{value}].")
      failure_message _("Could not update the setting")

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :description, _("Description")
        field :category_name, _("Category")
        field :settings_type, _("Settings type")
        field :value, _("Value")
      end

      build_options
    end


    autoload_subcommands
  end

end
