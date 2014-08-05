require 'hammer_cli_foreman/report'
require 'hammer_cli_foreman/puppet_class'
require 'hammer_cli_foreman/smart_class_parameter'

require 'highline/import'

module HammerCLIForeman

  module CommonHostUpdateOptions

    def self.included(base)
      base.option "--environment-id", "ENVIRONMENT_ID", " "
      base.option "--architecture-id", "ARCHITECTURE_ID", " "
      base.option "--domain-id", "DOMAIN_ID", " "
      base.option "--puppet-proxy-id", "PUPPET_PROXY_ID", " "
      base.option "--operatingsystem-id", "OPERATINGSYSTEM_ID", " "
      base.option "--partition-table-id", "PARTITION_TABLE_ID", " "
      base.option "--compute-resource-id", "COMPUTE_RESOURCE", " "
      base.option "--puppetclass-ids", "PUPPETCLASS_IDS", " ",
        :format => HammerCLI::Options::Normalizers::List.new
      base.option "--root-password", "ROOT_PW", " "
      base.option "--ask-root-password", "ASK_ROOT_PW", " ",
        :format => HammerCLI::Options::Normalizers::Bool.new


      bme_options = {}
      bme_options[:default] = 'true' if base.action.to_sym == :create

      bme_options[:format] = HammerCLI::Options::Normalizers::Bool.new
      base.option "--managed", "MANAGED", " ", bme_options
      bme_options[:format] = HammerCLI::Options::Normalizers::Bool.new
      base.option "--build", "BUILD", " ", bme_options
      bme_options[:format] = HammerCLI::Options::Normalizers::Bool.new
      base.option "--enabled", "ENABLED", " ",  bme_options

      base.option "--parameters", "PARAMS", _("Host parameters."),
        :format => HammerCLI::Options::Normalizers::KeyValueList.new
      base.option "--compute-attributes", "COMPUTE_ATTRS", _("Compute resource attributes."),
        :format => HammerCLI::Options::Normalizers::KeyValueList.new
      base.option "--volume", "VOLUME", _("Volume parameters"), :multivalued => true,
        :format => HammerCLI::Options::Normalizers::KeyValueList.new
      base.option "--interface", "INTERFACE", _("Interface parameters."), :multivalued => true,
        :format => HammerCLI::Options::Normalizers::KeyValueList.new
      base.option "--provision-method", "METHOD", " ",
        :format => HammerCLI::Options::Normalizers::Enum.new(['build', 'image'])

      base.build_options :without => [
            # - temporarily disabled params until they are fixed in API ------------------------
            # issue #3884
            :puppet_class_ids,
            # - temporarily disabled params that will be removed from the api ------------------
            :provision_method, :capabilities, :flavour_ref, :image_ref, :start,
            :network, :cpus, :memory, :provider, :type, :tenant_id, :image_id,
            # - avoids future conflicts as :root_pass is currently missing in the api docs
            :root_pass,
            # ----------------------------------------------------------------------------------
            :ptable_id, :host_parameters_attributes]
    end

    def self.ask_password
      prompt = "Enter the root password for the host: "
      ask(prompt) {|q| q.echo = false}
    end

    def request_params
      params = super

      params['host']['build'] = option_build unless option_build.nil?
      params['host']['managed'] = option_managed unless option_managed.nil?
      params['host']['enabled'] = option_enabled unless option_enabled.nil?

      params['host']['puppetclass_ids'] = option_puppetclass_ids unless option_puppetclass_ids.nil?

      params['host']['ptable_id'] = option_partition_table_id unless option_partition_table_id.nil?
      params['host']['compute_resource_id'] = option_compute_resource_id unless option_compute_resource_id.nil?
      params['host']['host_parameters_attributes'] = parameter_attributes
      params['host']['compute_attributes'] = option_compute_attributes || {}
      params['host']['compute_attributes']['volumes_attributes'] = nested_attributes(option_volume_list)
      if option_compute_resource_id
        params['host']['compute_attributes']['interfaces_attributes'] = nested_attributes(option_interface_list)
        params['host']['compute_attributes']['nics_attributes'] = nested_attributes(option_interface_list)
      else
        params['host']['interfaces_attributes'] = nested_attributes(option_interface_list)
      end

      params['host']['root_pass'] = option_root_password unless option_root_password.nil?

      if option_ask_root_password
        params['host']['root_pass'] = HammerCLIForeman::CommonHostUpdateOptions::ask_password
      end

      params
    end

    private

    def parameter_attributes
      return {} unless option_parameters
      option_parameters.collect do |key, value|
        {"name"=>key, "value"=>value, "nested"=>""}
      end
    end

    def nested_attributes(attrs)
      return {} unless attrs

      nested_hash = {}
      attrs.each_with_index do |attr, i|
        nested_hash[i.to_s] = attr
      end
      nested_hash
    end

  end


  class Host < HammerCLIForeman::Command

    resource :hosts

    class ListCommand < HammerCLIForeman::ListCommand
      # FIXME: list compute resource (model)
      output do
        field :id, _("Id")
        field :name, _("Name")
        field nil, _("Operating System"), Fields::SingleReference, :key => :operatingsystem
        field nil, _("Host Group"), Fields::SingleReference, :key => :hostgroup
        field :ip, _("IP")
        field :mac, _("MAC")
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      def extend_data(host)
        # FIXME: temporary fetching parameters until the api gets fixed.
        # Noramlly they should come in the host's json.
        # http://projects.theforeman.org/issues/5820
        host["parameters"] = get_parameters(host["id"])

        host["_bmc_interfaces"] =
          host["interfaces"].select{|intfs| intfs["type"] == "Nic::BMC" } rescue []
        host["_managed_interfaces"] =
          host["interfaces"].select{|intfs| intfs["type"] == "Nic::Managed" } rescue []
        host
      end

      def get_parameters(host_id)
        params = HammerCLIForeman.foreman_resource!(:parameters).call(:index, :host_id => host_id)
        HammerCLIForeman.collection_to_common_format(params)
      end

      output ListCommand.output_definition do
        field :uuid, _("UUID")
        field :certname, _("Cert name")

        field nil, _("Environment"), Fields::SingleReference, :key => :environment

        field :managed, _("Managed")
        field :enabled, _("Enabled")
        field :build, _("Build")

        field :use_image, _("Use image")
        field :disk, _("Disk")
        field :image_file, _("Image file")

        field :sp_name, _("SP Name")
        field :sp_ip, _("SP IP")
        field :sp_mac, _("SP MAC")

        field nil, _("SP Subnet"), Fields::SingleReference, :key => :sp_subnet

        field :installed_at, _("Installed at"), Fields::Date
        field :last_report, _("Last report"), Fields::Date

        field :puppet_ca_proxy_id, _("Puppet CA Proxy Id")
        field nil, _("Medium"), Fields::SingleReference, :key => :medium
        field nil, _("Model"), Fields::SingleReference, :key => :model
        field :owner_id, _("Owner Id")
        field nil, _("Subnet"), Fields::SingleReference, :key => :subnet
        field nil, _("Domain"), Fields::SingleReference, :key => :domain
        field :puppet_proxy_id, _("Puppet Proxy Id")
        field :owner_type, _("Owner Type")
        field nil, _("Partition Table"), Fields::SingleReference, :key => :ptable
        field nil, _("Architecture"), Fields::SingleReference, :key => :architecture
        field nil, _("Image"), Fields::SingleReference, :key => :image
        field nil, _("Compute Resource"), Fields::SingleReference, :key => :compute_resource

        field :comment, _("Comment")

        collection :_bmc_interfaces, _("BMC Network Interfaces"), :hide_blank => true do
          field :id, _("Id")
          field :name, _("Name")
          field :ip, _("IP")
          field :mac, _("MAC")
          field :domain_id, _("Domain Id")
          field :domain_name, _("Domain Name")
          field :subnet_id, _("Subnet Id")
          field :subnet_name, _("Subnet Name")
          field :username, _("BMC Username")
          field :password, _("BMC Password")
        end

        collection :_managed_interfaces, _("Managed Network Interfaces"), :hide_blank => true do
          field :id, _("Id")
          field :name, _("Name")
          field :ip, _("IP")
          field :mac, _("MAC")
          field :domain_id, _("Domain Id")
          field :domain_name, _("Domain Name")
          field :subnet_id, _("Subnet Id")
          field :subnet_name, _("Subnet Name")
        end

        HammerCLIForeman::References.parameters(self)
        HammerCLIForeman::References.timestamps(self)
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


    class PuppetClassesCommand < HammerCLIForeman::AssociatedResourceListCommand
      command_name "puppet-classes"
      resource :puppetclasses, :index
      parent_resource :hosts

      output HammerCLIForeman::PuppetClass::ListCommand.output_definition

      def send_request
        HammerCLIForeman::PuppetClass::ListCommand.unhash_classes(super)
      end

      build_options :without => [:host_id, :hostgroup_id, :environment_id]
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

      include HammerCLIForeman::CommonHostUpdateOptions

      def validate_options
        super
        unless validator.any(:option_hostgroup_id, :option_hostgroup_name).exist?
          if option_managed
            validator.all(:option_environment_id, :option_architecture_id, :option_domain_id,
                          :option_puppet_proxy_id, :option_operatingsystem_id,
                          :option_partition_table_id).required
          else
            # unmanaged host only requires environment
            validator.option(:option_environment_id).required
          end
        end
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Host updated")
      failure_message _("Could not update the host")

      include HammerCLIForeman::CommonHostUpdateOptions
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
          :cycle
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
      parent_resource :hosts
      build_options
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'host', _("Manipulate hosts."), HammerCLIForeman::Host
