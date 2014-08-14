require 'hammer_cli_foreman/smart_class_parameter'
require 'hammer_cli_foreman/puppet_class'

module HammerCLIForeman

  module HostgroupUpdateCreateCommons

    def self.included(base)
      base.option "--puppetclass-ids", "PUPPETCLASS_IDS", _("List of puppetclass ids"),
        :format => HammerCLI::Options::Normalizers::List.new
      base.option "--puppet-ca-proxy", "PUPPET_CA_PROXY_NAME", _("Name of puppet CA proxy")
      base.option "--puppet-proxy", "PUPPET_PROXY_NAME",  _("Name of puppet proxy")
    end

    def request_params
      params = super

      params['hostgroup']["puppet_proxy_id"] ||= proxy_id(option_puppet_proxy)
      params['hostgroup']["puppet_ca_proxy_id"] ||= proxy_id(option_puppet_ca_proxy)
      params['hostgroup']['puppetclass_ids'] = option_puppetclass_ids
      params
    end

    private

    def proxy_id(name)
      resolver.smart_proxy_id('option_name' => name) if name
    end

  end

  class Hostgroup < HammerCLIForeman::Command

    resource :hostgroups

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :label, _("Label")
        field nil, _("Operating System"), Fields::SingleReference, :key => :operatingsystem
        field nil, _("Environment"), Fields::SingleReference, :key => :environment
        field nil, _("Model"), Fields::SingleReference, :key => :model
        field :ancestry, _("Ancestry")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        field nil, _("Subnet"), Fields::SingleReference, :key => :subnet

        field nil, _("Domain"), Fields::SingleReference, :key => :domain
        field nil, _("Architecture"), Fields::SingleReference, :key => :architecture
        field nil, _("Partition Table"), Fields::SingleReference, :key => :ptable
        field nil, _("Medium"), Fields::SingleReference, :key => :medium
        field :puppet_ca_proxy_id, _("Puppet CA Proxy Id")
        field :puppet_proxy_id, _("Puppet Master Proxy Id")
        field nil, _("ComputeProfile"), Fields::SingleReference, :key => :compute_profile
        HammerCLIForeman::References.puppetclasses(self)
        HammerCLIForeman::References.parameters(self)
        HammerCLIForeman::References.taxonomies(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include HostgroupUpdateCreateCommons

      success_message _("Hostgroup created")
      failure_message _("Could not create the hostgroup")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
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
        params = super
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


