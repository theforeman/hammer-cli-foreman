require 'hammer_cli_foreman/smart_class_parameter'

module HammerCLIForeman

  module HostgroupUpdateCreateCommons

    def request_params
      params = method_options
      params['hostgroup']['puppetclass_ids'] = option_puppetclass_ids
      params
    end

  end

  class Hostgroup < HammerCLIForeman::Command

    resource :hostgroups

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :label, _("Label")
        field :operatingsystem_id, _("Operating System Id")
        field :subnet_id, _("Subnet Id")
        field :domain_id, _("Domain Id")
        field :architecture_id, _("Architecture Id")
        field :ptable_id, _("Partition Table Id")
        field :medium_id, _("Medium Id")
        field :puppet_ca_proxy_id, _("Puppet CA Proxy Id")
        field :puppet_proxy_id, _("Puppet Master Proxy Id")
        field :environment_id, _("Environment Id")
        field :puppetclass_ids, _("Puppetclass Ids"), Fields::List
        field :ancestry, _("Ancestry")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        collection :parameters, _("Parameters") do
          field nil, nil, Fields::KeyValue
        end
      end

      def extend_data(hostgroup)
        hostgroup["parameters"] = HammerCLIForeman::Parameter.get_parameters(:hostgroup, hostgroup["id"])
        hostgroup
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--puppetclass-ids", "PUPPETCLASS_IDS", " ",
        :format => HammerCLI::Options::Normalizers::List.new

      include HostgroupUpdateCreateCommons

      success_message _("Hostgroup created")
      failure_message _("Could not create the hostgroup")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      option "--puppetclass-ids", "PUPPETCLASS_IDS", " ",
        :format => HammerCLI::Options::Normalizers::List.new

      include HostgroupUpdateCreateCommons

      success_message _("Hostgroup updated")
      failure_message _("Could not update the hostgroup")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Hostgroup deleted")
      failure_message _("Could not delete the hostgroup")

      build_options
    end


    class PuppetClassesCommand < HammerCLIForeman::ListCommand
      command_name "puppet-classes"
      resource :puppetclasses

      output HammerCLIForeman::PuppetClass::ListCommand.output_definition

      def send_request
        HammerCLIForeman::PuppetClass::ListCommand.unhash_classes(super)
      end

      def request_params
        params = method_options
        params['hostgroup_id'] = get_identifier
        params
      end

      build_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand
      desc _("Create or update parameter for a hostgroup.")

      success_message_for :update, _("Hostgroup parameter updated")
      success_message_for :create, _("New hostgroup parameter created")
      failure_message _("Could not set hostgroup parameter")

      build_options
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand
      desc _("Delete parameter for a hostgroup.")

      success_message _("Hostgroup parameter deleted")

      build_options
    end

    class SCParamsCommand < HammerCLIForeman::SmartClassParametersList
      parent_resource :hostgroups
      build_options
    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'hostgroup', _("Manipulate hostgroups."), HammerCLIForeman::Hostgroup
