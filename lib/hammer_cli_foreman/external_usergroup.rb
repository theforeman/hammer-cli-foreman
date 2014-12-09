require 'hammer_cli_foreman/usergroup'

module HammerCLIForeman
  class ExternalUsergroup < HammerCLIForeman::Command
    resource :external_usergroups
    desc _("View and manage user group's external user groups")

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :_auth_source, _("Auth source"), Fields::Reference
      end

      def extend_data(record)
        key = record.keys.find{ |k| k =~ /^auth_source/ }
        record['_auth_source'] = record[key]
        record
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition

      def extend_data(record)
        key = record.keys.find{ |k| k =~ /^auth_source/ }
        record['_auth_source'] = record[key]
        record
      end

      build_options
    end

    class RefreshExternalUsergroupsCommand < HammerCLIForeman::ListCommand
      action :refresh
      command_name 'refresh'
      desc _("Refresh external user group")

      output do
        field :name, _("Name")
        field :_auth_source, _("Auth source")
      end

      def extend_data(record)
        key = record.keys.find{ |k| k =~ /^auth_source/ }
        record['_auth_source'] = record[key]
        record
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("External user group created")
      failure_message _("Could not create external user group")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("External user group updated")
      failure_message _("Could not update external user group")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("External user group deleted")
      failure_message _("Could not delete the external user group")

      build_options
    end

    autoload_subcommands
  end

end

