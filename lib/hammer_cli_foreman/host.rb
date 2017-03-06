require 'hammer_cli_foreman/fact'
require 'hammer_cli_foreman/report'
require 'hammer_cli_foreman/puppet_class'
require 'hammer_cli_foreman/smart_class_parameter'
require 'hammer_cli_foreman/smart_variable'
require 'hammer_cli_foreman/interface'
require 'hammer_cli_foreman/hosts/common_update_options'
require 'hammer_cli_foreman/hosts/common_update_help'

require 'highline/import'

module HammerCLIForeman


  class Host < HammerCLIForeman::Command

    resource :hosts

    def self.extend_cr_help(cr)
      cr_help_extensions[cr.name] = cr.method(:host_create_help)
    end

    def self.cr_help_extensions
      @cr_help_extensions ||= {}
    end

    class ListCommand < HammerCLIForeman::ListCommand
      # FIXME: list compute resource (model)
      output do
        field :id, _("Id")
        field :name, _("Name")
        field nil, _("Operating System"), Fields::SingleReference, :key => :operatingsystem
        field nil, _("Host Group"), Fields::SingleReference, :key => :hostgroup, :display_field => 'title'
        field :ip, _("IP")
        field :mac, _("MAC")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      def extend_data(host)
        host['compute_resource_name'] ||= _('Bare Metal')
        host['image_file'] = nil if host['image_file'].empty?
        host['interfaces'] = host['interfaces'].map do |nic|
          nic['_type'] = HammerCLIForeman::Interface.format_type(nic)
          nic
        end if host['interfaces']

        host
      end

      def get_parameters(host_id)
        params = HammerCLIForeman.foreman_resource!(:parameters).call(:index, :host_id => host_id)
        HammerCLIForeman.collection_to_common_format(params)
      end


      output do
        field :id, _("Id")
        field :uuid, _("UUID"), Fields::Field, :hide_blank => true
        field :name, _("Name")
        field nil, _("Organization"), Fields::SingleReference, :key => :organization, :hide_blank => true
        field nil, _("Location"), Fields::SingleReference, :key => :location, :hide_blank => true
        field nil, _("Host Group"), Fields::SingleReference, :key => :hostgroup, :display_field => 'title'
        field nil, _("Compute Resource"), Fields::SingleReference, :key => :compute_resource
        field nil, _("Compute Profile"), Fields::SingleReference, :key => :compute_profile, :hide_blank => true
        field nil, _("Environment"), Fields::SingleReference, :key => :environment
        field :puppet_ca_proxy_id, _("Puppet CA Id")
        field :puppet_proxy_id, _("Puppet Master Id")
        field :certname, _("Cert name")
        field :managed, _("Managed"), Fields::Boolean

        field :installed_at, _("Installed at"), Fields::Date
        field :last_report, _("Last report"), Fields::Date

        label _("Network") do
          field :ip, _("IP")
          field :mac, _("MAC")
          field nil, _("Subnet"), Fields::SingleReference, :key => :subnet
          field nil, _("Domain"), Fields::SingleReference, :key => :domain
          field nil, _("Service provider"), Fields::Label, :hide_blank => true do
            field :sp_name, _("SP Name"), Fields::Field, :hide_blank => true
            field :sp_ip, _("SP IP"), Fields::Field, :hide_blank => true
            field :sp_mac, _("SP MAC"), Fields::Field, :hide_blank => true
            field nil, _("SP Subnet"), Fields::SingleReference, :key => :sp_subnet, :hide_blank => true
          end
        end

        collection :interfaces, _("Network interfaces") do
          field :id, _('Id')
          field :identifier, _('Identifier')
          field :_type, _('Type')
          field :mac, _('MAC address')
          field :ip, _('IP address')
          field :fqdn, _('FQDN')
        end

        label _("Operating system") do
          field nil, _("Architecture"), Fields::SingleReference, :key => :architecture
          field nil, _("Operating System"), Fields::SingleReference, :key => :operatingsystem
          # provision_method
          # for network based
          field :build, _("Build"), Fields::Boolean
          field nil, _("Medium"), Fields::SingleReference, :key => :medium
          field nil, _("Partition Table"), Fields::SingleReference, :key => :ptable
          field :disk, _("Custom partition table"), Fields::LongText
          # image
          # for image based
          field nil, _("Image"), Fields::SingleReference, :key => :image, :hide_blank => true
          field :image_file, _("Image file"), Fields::Field, :hide_blank => true
          field :use_image, _("Use image"), Fields::Boolean, :hide_blank => true
        end

        HammerCLIForeman::References.parameters(self)

        # additional info
        label _("Additional info") do
          field :owner_id, _("Owner Id")
          field :owner_type, _("Owner Type")
          field :enabled, _("Enabled"), Fields::Boolean
          field nil, _("Model"), Fields::SingleReference, :key => :model, :hide_blank => true
          field :comment, _("Comment"), Fields::LongText
        end
      end

      build_options
    end


    class StatusCommand < HammerCLIForeman::SingleResourceCommand
      command_name "status"
      action :status

      output do
        field :status, _("Status")
        field :power, _("Power")
      end

      def send_request
        {
          :status => get_status,
          :power => get_power_status
        }
      end

      def get_status
        params = {
          'id' => get_identifier,
        }
        status = resource.call(:status, params)
        status["status"]
      end

      def get_power_status
        params = {
          'id' => get_identifier,
          'power_action' => :state
        }
        status = resource.call(:power, params)
        status["power"]
      end

      build_options
    end


    class PuppetRunCommand < HammerCLIForeman::SingleResourceCommand
      command_name "puppetrun"
      action :puppetrun

      def print_data(records)
        print_message _('Puppet run triggered')
      end

      build_options
    end


    class FactsCommand < HammerCLIForeman::AssociatedResourceListCommand
      command_name "facts"
      resource :fact_values, :index
      parent_resource :hosts

      output do
        field :fact, _("Fact")
        field :value, _("Value")
      end

      def send_request
        HammerCLIForeman::Fact::ListCommand.unhash_facts(super)
      end

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
        o.without(:hostgroup_id, :environment_id)
        o.expand.only(:hosts)
      end
    end


    class ReportsCommand < HammerCLIForeman::AssociatedResourceListCommand
      command_name "reports"
      resource :reports, :index
      parent_resource :hosts

      output HammerCLIForeman::Report::ListCommand.output_definition

      build_options
    end

    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Host created")
      failure_message _("Could not create the host")

      include HammerCLIForeman::Hosts::CommonUpdateOptions
      include HammerCLIForeman::Hosts::CommonUpdateHelp

      def validate_options
        super
        unless validator.any(:option_hostgroup_id, :option_hostgroup_name).exist?
          if option_managed
            validator.any(:option_architecture_name, :option_architecture_id).required
            validator.any(:option_domain_name, :option_domain_id).required
            validator.any(:option_operatingsystem_title, :option_operatingsystem_id).required
            validator.any(:option_ptable_name, :option_ptable_id).required
          end
        end
      end

    end

    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Host updated")
      failure_message _("Could not update the host")

      include HammerCLIForeman::Hosts::CommonUpdateOptions
      include HammerCLIForeman::Hosts::CommonUpdateHelp
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Host deleted")
      failure_message _("Could not delete the host")

      build_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand
      desc _("Create or update parameter for a host.")

      success_message_for :update, _("Host parameter updated")
      success_message_for :create, _("New host parameter created")
      failure_message _("Could not set host parameter")

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end

      build_options
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand
      desc _("Delete parameter for a host.")

      success_message _("Host parameter deleted")

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end

      build_options
    end


    class StartCommand < HammerCLIForeman::SingleResourceCommand
      action :power

      command_name "start"
      desc _("Power a host on")
      success_message _("The host is starting.")

      def option_power_action
        :start
      end

      def request_params
        params = super
        params['id'] = get_identifier
        params
      end

      build_options :without => :power_action
    end


    class StopCommand < HammerCLIForeman::SingleResourceCommand
      option '--force', :flag, _("Force turning off a host")

      action :power

      command_name "stop"
      desc _("Power a host off")

      def option_power_action
        if option_force?
          :poweroff
        else
          :stop
        end
      end

      def success_message
        if option_force?
          _("Power off forced.")
        else
          _("Powering the host off.")
        end
      end

      def request_params
        params = super
        params['id'] = get_identifier
        params
      end

      build_options :without => :power_action
    end

    class RebootCommand < HammerCLIForeman::SingleResourceCommand
      action :power

      command_name "reboot"
      desc _("Reboot a host")
      success_message _("Host reboot started.")

      def option_power_action
        :soft
      end

      def request_params
        params = super
        params['id'] = get_identifier
        params
      end

      build_options :without => :power_action
    end

    class SCParamsCommand < HammerCLIForeman::SmartClassParametersList
      build_options_for :hosts

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end
    end

    class SmartVariablesCommand < HammerCLIForeman::SmartVariablesList
      build_options_for :hosts

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end
    end

    class RebuildConfigCommand < HammerCLIForeman::SingleResourceCommand
      action :rebuild_config
      command_name "rebuild-config"
      desc _('Rebuild orchestration related configurations for host')
      success_message _('Configuration successfully rebuilt.')

      build_options
    end

    autoload_subcommands

    subcommand 'interface', HammerCLIForeman::Interface.desc, HammerCLIForeman::Interface
  end

end

require 'hammer_cli_foreman/compute_resources/all'
