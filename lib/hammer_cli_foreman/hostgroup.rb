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

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      identifiers :id

      output ListCommand.output_definition do
        collection :parameters, _("Parameters") do
          field nil, nil, Fields::KeyValue
        end
      end

      def extend_data(hostgroup)
        hostgroup["parameters"] = HammerCLIForeman::Parameter.get_parameters(resource_config, :hostgroup, hostgroup)
        hostgroup
      end

      apipie_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      option "--puppetclass-ids", "PUPPETCLASS_IDS", " ",
        :format => HammerCLI::Options::Normalizers::List.new

      include HostgroupUpdateCreateCommons

      success_message _("Hostgroup created")
      failure_message _("Could not create the hostgroup")

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      option "--puppetclass-ids", "PUPPETCLASS_IDS", " ",
        :format => HammerCLI::Options::Normalizers::List.new

      include HostgroupUpdateCreateCommons

      identifiers :id

      success_message _("Hostgroup updated")
      failure_message _("Could not update the hostgroup")

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id

      success_message _("Hostgroup deleted")
      failure_message _("Could not delete the hostgroup")

      apipie_options
    end


    class PuppetClassesCommand < HammerCLIForeman::ListCommand

      command_name "puppet_classes"
      resource :puppetclasses

      identifiers :id

      output HammerCLIForeman::PuppetClass::ListCommand.output_definition

      def retrieve_data
        HammerCLIForeman::PuppetClass::ListCommand.unhash_classes(super)
      end

      def request_params
        params = method_options
        params['hostgroup_id'] = get_identifier[0]
        params
      end

      apipie_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand

      resource :parameters

      desc _("Create or update parameter for a hostgroup.")

      option "--hostgroup-id", "HOSTGROUP_ID", _("id of the hostgroup the parameter is being set for"), :required => true

      success_message_for :update, _("Hostgroup parameter updated")
      success_message_for :create, _("New hostgroup parameter created")
      failure_message _("Could not set hostgroup parameter")

      def base_action_params
        {
          "hostgroup_id" => option_hostgroup_id
        }
      end
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand

      resource :parameters

      desc _("Delete parameter for a hostgroup.")

      option "--hostgroup-id", "HOSTGROUP_ID", _("id of the hostgroup the parameter is being deleted for"), :required => true

      success_message _("Hostgroup parameter deleted")

      def base_action_params
        {
          "hostgroup_id" => option_hostgroup_id
        }
      end
    end


    class SCParamsCommand < HammerCLIForeman::SmartClassParametersList

      apipie_options :without => [:host_id, :hostgroup_id, :puppetclass_id, :environment_id]
      option ['--id', '--name'], 'HOSTGROUP_ID', _('hostgroup id/name'),
            :attribute_name => :option_hostgroup_id, :required => true
    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'hostgroup', _("Manipulate hostgroups."), HammerCLIForeman::Hostgroup
