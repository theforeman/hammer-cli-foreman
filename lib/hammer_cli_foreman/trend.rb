module HammerCLIForeman

  class Trend < HammerCLIForeman::Command

    resource :trends

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :label, _("Label")
      end

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Trend for %<trendable_type>s created.")
      failure_message _("Could not create the trend")

      build_options
    end

    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Trend for %<trendable_type>s deleted.")
      failure_message _("Could not delete the trend")

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output do
        field :id, _('Id')
        field :name, _('Name')
        field :label, _("Label")
        field :trendable_type, _('Type')
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end

    autoload_subcommands
  end
end

