require 'hammer_cli_foreman/report'
require 'hammer_cli_foreman/puppet_class'
require 'hammer_cli_foreman/smart_class_parameter'

require 'highline/import'

module HammerCLIForeman

  module CommonHostUpdateOptions

    def self.included(base)
      base.apipie_options :without => [:host_parameters_attributes, :environment_id, :architecture_id, :domain_id,
            :puppet_proxy_id, :operatingsystem_id,
            # - temporarily disabled params until we add support for boolean options to apipie -
            :build, :managed, :enabled, :start,
            # - temporarily disabled params until they are fixed in API
            :puppet_class_ids, #3884
            # - temporarily disabled params that will be removed from the api ------------------
            :provision_method, :capabilities, :flavour_ref, :image_ref, :start,
            :network, :cpus, :memory, :provider, :type, :tenant_id, :image_id,
            # - avoids future conflicts as :root_pass is currently missing in the api docs
            :root_pass,
            # ----------------------------------------------------------------------------------
            :compute_resource_id, :ptable_id] + base.declared_identifiers.keys

      base.option "--environment-id", "ENVIRONMENT_ID", " "
      base.option "--architecture-id", "ARCHITECTURE_ID", " "
      base.option "--domain-id", "DOMAIN_ID", " "
      base.option "--puppet-proxy-id", "PUPPET_PROXY_ID", " "
      base.option "--operatingsystem-id", "OPERATINGSYSTEM_ID", " "
      base.option "--partition-table-id", "PARTITION_TABLE_ID", " "
      base.option "--compute-resource-id", "COMPUTE_RESOURCE", " "
      base.option "--partition-table-id", "PARTITION_TABLE", " "
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
        field :operatingsystem_id, _("Operating System Id")
        field :hostgroup_id, _("Host Group Id")
        field :ip, _("IP")
        field :mac, _("MAC")
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      def extend_data(host)
        host["environment_name"] = host["environment"]["environment"]["name"] rescue nil
        host["parameters"] = HammerCLIForeman::Parameter.get_parameters(resource_config, :host, host)
        host["_bmc_interfaces"] =
          host["interfaces"].select{|intfs| intfs["type"] == "Nic::BMC" } rescue []
        host["_managed_interfaces"] =
          host["interfaces"].select{|intfs| intfs["type"] == "Nic::Managed" } rescue []
        host
      end

      output ListCommand.output_definition do
        field :uuid, _("UUID")
        field :certname, _("Cert name")

        field :environment_name, _("Environment")
        field :environment_id, _("Environment Id")

        field :managed, _("Managed")
        field :enabled, _("Enabled")
        field :build, _("Build")

        field :use_image, _("Use image")
        field :disk, _("Disk")
        field :image_file, _("Image file")

        field :sp_name, _("SP Name")
        field :sp_ip, _("SP IP")
        field :sp_mac, _("SP MAC")
        field :sp_subnet, _("SP Subnet")
        field :sp_subnet_id, _("SP Subnet Id")

        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
        field :installed_at, _("Installed at"), Fields::Date
        field :last_report, _("Last report"), Fields::Date

        field :puppet_ca_proxy_id, _("Puppet CA Proxy Id")
        field :medium_id, _("Medium Id")
        field :model_id, _("Model Id")
        field :owner_id, _("Owner Id")
        field :subnet_id, _("Subnet Id")
        field :domain_id, _("Domain Id")
        field :puppet_proxy_id, _("Puppet Proxy Id")
        field :owner_type, _("Owner Type")
        field :ptable_id, _("Partition Table Id")
        field :architecture_id, _("Architecture Id")
        field :image_id, _("Image Id")
        field :compute_resource_id, _("Compute Resource Id")

        field :comment, _("Comment")

        collection :parameters, _("Parameters") do
          field nil, nil, Fields::KeyValue
        end

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

      end

      apipie_options
    end


    class StatusCommand < HammerCLI::Apipie::ReadCommand

      identifiers :id, :name

      command_name "status"

      output do
        field :status, _("Status")
        field :power, _("Power")
      end

      def retrieve_data
        {
          :status => get_status,
          :power => get_power_status
        }
      end

      def get_status
        params = {
          'id' => get_identifier[0],
        }
        status = resource.call(:status, params)
        status["status"]
      end

      def get_power_status
        params = {
          'id' => get_identifier[0],
          'power_action' => :state
        }
        status = resource.call(:power, params)
        status["power"]
      end

      apipie_options
    end


    class PuppetRunCommand < HammerCLIForeman::InfoCommand

      command_name "puppetrun"
      action :puppetrun

      def print_data(records)
        print_message _('Puppet run triggered')
      end

      apipie_options
    end


    class FactsCommand < HammerCLIForeman::ListCommand

      command_name "facts"
      resource :fact_values, :index
      identifiers :id, :name

      apipie_options :without => declared_identifiers.keys

      output do
        field :fact, _("Fact")
        field :value, _("Value")
      end

      def request_params
        params = method_options
        params['host_id'] = get_identifier[0]
        params
      end

      def retrieve_data
        data = super
        HammerCLIForeman::Fact::ListCommand.unhash_facts(data)
      end

    end


    class PuppetClassesCommand < HammerCLIForeman::ListCommand

      command_name "puppet-classes"
      resource :puppetclasses

      identifiers :id, :name

      output HammerCLIForeman::PuppetClass::ListCommand.output_definition

      def retrieve_data
        HammerCLIForeman::PuppetClass::ListCommand.unhash_classes(super)
      end

      def request_params
        params = method_options
        params['host_id'] = get_identifier[0]
        params
      end

      apipie_options
    end


    class ReportsCommand < HammerCLIForeman::ListCommand

      identifiers :id, :name

      command_name "reports"
      resource :reports
      output HammerCLIForeman::Report::ListCommand.output_definition

      apipie_options :without => :search

      def search
        'host.id = %s' % get_identifier[0].to_s
      end
    end

    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message _("Host created")
      failure_message _("Could not create the host")

      include HammerCLIForeman::CommonHostUpdateOptions

      def validate_options
        super
        unless validator.option(:option_hostgroup_id).exist?
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

      apipie_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand

      resource :parameters

      desc _("Create or update parameter for a host.")

      option "--host-name", "HOST_NAME", _("name of the host the parameter is being set for")
      option "--host-id", "HOST_ID", _("id of the host the parameter is being set for")

      success_message_for :update, _("Host parameter updated")
      success_message_for :create, _("New host parameter created")
      failure_message _("Could not set host parameter")

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end

      def base_action_params
        {
          "host_id" => option_host_id || option_host_name
        }
      end
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand

      resource :parameters

      desc _("Delete parameter for a host.")

      option "--host-name", "HOST_NAME", _("name of the host the parameter is being deleted for")
      option "--host-id", "HOST_ID", _("id of the host the parameter is being deleted for")

      success_message _("Host parameter deleted")

      def validate_options
        super
        validator.any(:option_host_name, :option_host_id).required
      end

      def base_action_params
        {
          "host_id" => option_host_id || option_host_name
        }
      end
    end


    class StartCommand < HammerCLI::Apipie::WriteCommand

      identifiers :id, :name
      action :power

      command_name "start"
      desc _("Power a host on")
      success_message _("The host is starting.")

      def option_power_action
        :start
      end

      def request_params
        params = method_options
        params['id'] = get_identifier[0]
        params
      end

      apipie_options :without => :power_action
    end


    class StopCommand < HammerCLI::Apipie::WriteCommand

      option '--force', :flag, _("Force turning off a host")

      identifiers :id, :name
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
        params = method_options
        params['id'] = get_identifier[0]
        params
      end

      apipie_options :without => :power_action
    end

    class RebootCommand < HammerCLI::Apipie::WriteCommand

      identifiers :id, :name
      action :power

      command_name "reboot"
      desc _("Reboot a host")
      success_message _("Host reboot started.")

      def option_power_action
        :soft
      end

      def request_params
        params = method_options
        params['id'] = get_identifier[0]
        params
      end

      apipie_options :without => :power_action
    end

    class SCParamsCommand < HammerCLIForeman::SmartClassParametersList

      apipie_options :without => [:host_id, :hostgroup_id, :puppetclass_id, :environment_id]
      option ['--id', '--name'], 'HOST_ID', _('host id/name'),
              :attribute_name => :option_host_id, :required => true
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'host', ("Manipulate hosts."), HammerCLIForeman::Host
