require 'hammer_cli_foreman/smart_class_parameter'
require 'hammer_cli_foreman/puppet_class'

module HammerCLIForeman

  module HostgroupUpdateCreateCommons

    def self.included(base)
      base.option "--puppet-class-ids", "PUPPETCLASS_IDS", _("List of puppetclass ids"),
        :format => HammerCLI::Options::Normalizers::List.new,
        :attribute_name => :option_puppetclass_ids
      base.option "--puppet-classes", "PUPPET_CLASS_NAMES", "",
        :format => HammerCLI::Options::Normalizers::List.new,
        :attribute_name => :option_puppetclass_names
      base.option "--puppet-ca-proxy", "PUPPET_CA_PROXY_NAME", _("Name of puppet CA proxy")
      base.option "--puppet-proxy", "PUPPET_PROXY_NAME",  _("Name of puppet proxy")
      base.option "--parent", "PARENT_NAME",  _("Name of parent hostgroup")
      base.option ["--root-password", "--root-pass"], "ROOT_PASSWORD",  _("Root password"),
                  deprecated: { '--root-pass' => _("Use --root-password instead") }
      base.option ["--ask-root-password", "--ask-root-pass"], "ASK_ROOT_PW", "",
                  format: HammerCLI::Options::Normalizers::Bool.new,
                  deprecated: { '--ask-root-pass' => _("Use --ask-root-password instead") }
      base.option "--subnet6", "SUBNET6_NAME", _("Subnet IPv6 name")

      base.build_options without: %i[root_pass]
    end

    def self.ask_password
      prompt = _("Enter the root password for the host group:") + " "
      HammerCLI.interactive_output.ask(prompt) { |q| q.echo = false }
    end

    def request_params
      params = super
      params['hostgroup']["parent_id"] ||= resolver.hostgroup_id('option_name' => option_parent) if option_parent
      params['hostgroup']["puppet_proxy_id"] ||= proxy_id(option_puppet_proxy) if option_puppet_proxy
      params['hostgroup']["puppet_ca_proxy_id"] ||= proxy_id(option_puppet_ca_proxy) if option_puppet_ca_proxy

      params['hostgroup']['root_pass'] = option_root_password if option_root_password
      params['hostgroup']['root_pass'] = HammerCLIForeman::HostgroupUpdateCreateCommons::ask_password if option_ask_root_password

      params['hostgroup']['subnet6_id'] = resolver.subnet_id('option_name' => option_subnet6) if option_subnet6
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
        field :title, _("Title")
        field nil, _("Operating System"), Fields::SingleReference, :key => :operatingsystem
        field nil, _("Puppet Environment"), Fields::SingleReference, :key => :environment
        field nil, _("Model"), Fields::SingleReference, :key => :model
      end

      build_options :without => :include
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output do
        field :id, _("Id")
        field :name, _("Name")
        field :title, _("Title")
        field nil, _("Puppet Environment"), Fields::SingleReference, :key => :environment
        field nil, _("Model"), Fields::SingleReference, :key => :model

        field :description, _("Description"), Fields::LongText, :hide_blank => true
        field nil, _("Parent"), Fields::SingleReference, :key => :parent, :hide_blank => true
        field nil, _("Puppet CA Proxy"), Fields::SingleReference, :key => :puppet_ca_proxy
        field nil, _("Puppet Master Proxy"), Fields::SingleReference, :key => :puppet_proxy
        field nil, _("ComputeProfile"), Fields::SingleReference, :key => :compute_profile
        label _('Network') do
          field nil, _("Subnet ipv4"), Fields::SingleReference, :key => :subnet
          field nil, _("Subnet ipv6"), Fields::SingleReference, :key => :subnet6
          field nil, _("Realm"), Fields::SingleReference, :key => :realm
          field nil, _("Domain"), Fields::SingleReference, :key => :domain
        end
        label _('Operating system') do
          field nil, _("Architecture"), Fields::SingleReference, :key => :architecture
          field nil, _("Operating System"), Fields::SingleReference, :key => :operatingsystem
          field nil, _("Medium"), Fields::SingleReference, :key => :medium
          field nil, _("Partition Table"), Fields::SingleReference, :key => :ptable
          field :pxe_loader, _("PXE Loader"), Fields::Field, :hide_blank => true
        end
        HammerCLIForeman::References.puppetclasses(self)
        HammerCLIForeman::References.parameters(self)
        HammerCLIForeman::References.taxonomies(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include HostgroupUpdateCreateCommons

      success_message _("Hostgroup created.")
      failure_message _("Could not create the hostgroup")

      extend_with(HammerCLIForeman::CommandExtensions::PuppetEnvironment.new)
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include HostgroupUpdateCreateCommons

      success_message _("Hostgroup updated.")
      failure_message _("Could not update the hostgroup")

      extend_with(HammerCLIForeman::CommandExtensions::PuppetEnvironment.new)
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Hostgroup deleted.")
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

      build_options do |o|
        o.without(:host_id, :environment_id)
        o.expand.only(:hostgroups)
      end
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand
      desc _("Create or update parameter for a hostgroup")

      success_message_for :update, _("Hostgroup parameter updated")
      success_message_for :create, _("New hostgroup parameter created")
      failure_message _("Could not set hostgroup parameter")

      build_options
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand
      desc _("Delete parameter for a hostgroup")

      success_message _("Hostgroup parameter deleted.")

      build_options
    end

    class SCParamsCommand < HammerCLIForeman::SmartClassParametersList
      build_options_for :hostgroups

      def validate_options
        super
        validator.any(:option_hostgroup_name, :option_hostgroup_id).required
      end
    end

    class RebuildConfigCommand < HammerCLIForeman::SingleResourceCommand
      action :rebuild_config
      command_name "rebuild-config"
      success_message _('Configuration successfully rebuilt.')
      failure_message _('Could not rebuild configuration')

      build_options
    end

    autoload_subcommands
  end

end
