require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/parameter'
require 'hammer_cli_foreman/report'
require 'hammer_cli_foreman/puppet_class'
require 'hammer_cli_foreman/smart_class_parameter'

module HammerCLIForeman

  module CommonHostUpdateOptions

    def self.included(base)
      base.apipie_options :without => [:host_parameters_attributes, :environment_id, :architecture_id, :domain_id,
            :puppet_proxy_id, :operatingsystem_id,
            # - temporarily disabled params until we add support for boolean options to apipie -
            :build, :managed, :enabled, :start,
            # - temporarily disabled params that will be removed from the api ------------------
            :provision_method, :capabilities, :flavour_ref, :image_ref, :start,
            :network, :cpus, :memory, :provider, :type, :tenant_id, :image_id,
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

      base.option "--build", "BUILD", " ", :default => 'true',
        :format => HammerCLI::Options::Normalizers::Bool.new
      base.option "--managed", "MANAGED", " ", :default => 'true',
        :format => HammerCLI::Options::Normalizers::Bool.new
      base.option "--enabled", "ENABLED", " ",  :default => 'true',
        :format => HammerCLI::Options::Normalizers::Bool.new

      base.option "--parameters", "PARAMS", "Host parameters.",
        :format => HammerCLI::Options::Normalizers::KeyValueList.new
      base.option "--compute-attributes", "COMPUTE_ATTRS", "Compute resource attributes.",
        :format => HammerCLI::Options::Normalizers::KeyValueList.new
      base.option "--volume", "VOLUME", "Volume parameters", :multivalued => true,
        :format => HammerCLI::Options::Normalizers::KeyValueList.new
      base.option "--interface", "INTERFACE", "Interface parameters.", :multivalued => true,
        :format => HammerCLI::Options::Normalizers::KeyValueList.new

    end

    def request_params
      params = super

      params['host']['build'] = build
      params['host']['managed'] = managed
      params['host']['enabled'] = enabled

      params['host']['ptable_id'] = partition_table_id
      params['host']['compute_resource_id'] = compute_resource_id
      params['host']['host_parameters_attributes'] = parameter_attributes
      params['host']['compute_attributes'] = compute_attributes || {}
      params['host']['compute_attributes']['volumes_attributes'] = nested_attributes(volume_list)
      params['host']['compute_attributes']['interfaces_attributes'] = nested_attributes(interface_list)
      params['host']['compute_attributes']['nics_attributes'] = nested_attributes(interface_list)

      params
    end

    private

    def parameter_attributes
      return {} unless parameters
      parameters.collect do |key, value|
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


  class Host < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Host

    class ListCommand < HammerCLIForeman::ListCommand
      # FIXME: list compute resource (model)
      output do
        from "host" do
          field :id, "Id"
          field :name, "Name"
          field :operatingsystem_id, "Operating System Id"
          field :hostgroup_id, "Host Group Id"
          field :ip, "IP"
          field :mac, "MAC"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      def retrieve_data
        host = super
        host["host"]["environment_name"] = host["host"]["environment"]["environment"]["name"] rescue nil
        host["parameters"] = HammerCLIForeman::Parameter.get_parameters(resource_config, host)
        host
      end

      output ListCommand.output_definition do
        from "host" do
          field :uuid, "UUID"
          field :certname, "Cert name"

          field :environment_name, "Environment"
          field :environment_id, "Environment Id"

          field :managed, "Managed"
          field :enabled, "Enabled"
          field :build, "Build"

          field :use_image, "Use image"
          field :disk, "Disk"
          field :image_file, "Image file"

          field :sp_name, "SP Name"
          field :sp_ip, "SP IP"
          field :sp_mac, "SP MAC"
          field :sp_subnet, "SP Subnet"
          field :sp_subnet_id, "SP Subnet Id"

          field :created_at, "Created at", Fields::Date
          field :updated_at, "Updated at", Fields::Date
          field :installed_at, "Installed at", Fields::Date
          field :last_report, "Last report", Fields::Date

          field :puppet_ca_proxy_id, "Puppet CA Proxy Id"
          field :medium_id, "Medium Id"
          field :model_id, "Model Id"
          field :owner_id, "Owner Id"
          field :subnet_id, "Subnet Id"
          field :domain_id, "Domain Id"
          field :puppet_proxy_id, "Puppet Proxy Id"
          field :owner_type, "Owner Type"
          field :ptable_id, "Partition Table Id"
          field :architecture_id, "Architecture Id"
          field :image_id, "Image Id"
          field :compute_resource_id, "Compute Resource Id"

          field :comment, "Comment"
        end
        collection :parameters, "Parameters" do
          field :parameter, nil, Fields::KeyValue
        end
      end
    end


    class StatusCommand < HammerCLI::Apipie::ReadCommand

      identifiers :id, :name

      command_name "status"

      output do
        field :status, "Status"
        field :power, "Power"
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
        status = resource.call(:status, params)[0]
        status["status"]
      end

      def get_power_status
        params = {
          'id' => get_identifier[0],
          'power_action' => :state
        }
        status = resource.call(:power, params)[0]
        status["power"]
      end
    end


    class PuppetRunCommand < HammerCLIForeman::InfoCommand

      command_name "puppetrun"
      action "puppetrun"

      def print_data(records)
        print_message 'Puppet run triggered'
      end
    end


    class FactsCommand < HammerCLIForeman::ListCommand

      command_name "facts"
      resource ForemanApi::Resources::FactValue, "index"
      identifiers :id, :name

      apipie_options :without => declared_identifiers.keys

      output do
        from "fact" do
          field :fact, "Fact"
          field :value, "Value"
        end
      end

      def request_params
        params = method_options
        params['host_id'] = get_identifier[0]
        params
      end

      def retrieve_data
        HammerCLIForeman::Fact::ListCommand.unhash_facts(super)
      end

    end


    class PuppetClassesCommand < HammerCLIForeman::ListCommand

      command_name "puppet_classes"
      resource ForemanApi::Resources::Puppetclass

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
      resource ForemanApi::Resources::Report
      output HammerCLIForeman::Report::ListCommand.output_definition

      apipie_options :without => :search

      def search
        'host.id = %s' % get_identifier[0].to_s
      end

    end

    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Host created"
      failure_message "Could not create the host"
      action "create"

      include HammerCLIForeman::CommonHostUpdateOptions

      validate_options do
        unless option(:hostgroup_id).exist?
          all(:environment_id, :architecture_id, :domain_id,
            :puppet_proxy_id, :operatingsystem_id,
            :partition_table_id).required
        end
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Host updated"
      failure_message "Could not update the host"

      include HammerCLIForeman::CommonHostUpdateOptions
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Host deleted"
      failure_message "Could not delete the host"

      apipie_options
    end


    class SetParameterCommand < HammerCLIForeman::Parameter::SetCommand

      desc "Create or update parameter for a host."

      option "--host-name", "HOST_NAME", "name of the host the parameter is being set for"
      option "--host-id", "HOST_ID", "id of the host the parameter is being set for"

      success_message_for :update, "Host parameter updated"
      success_message_for :create, "New host parameter created"
      failure_message "Could not set host parameter"

      def validate_options
        super
        validator.any(:host_name, :host_id).required
      end

      def base_action_params
        {
          "host_id" => host_id || host_name
        }
      end
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand

      desc "Delete parameter for a host."

      option "--host-name", "HOST_NAME", "name of the host the parameter is being deleted for"
      option "--host-id", "HOST_ID", "id of the host the parameter is being deleted for"

      success_message "Host parameter deleted"

      def validate_options
        super
        validator.any(:host_name, :host_id).required
      end

      def base_action_params
        {
          "host_id" => host_id || host_name
        }
      end
    end


    class StartCommand < HammerCLI::Apipie::WriteCommand

      identifiers :id, :name
      action "power"

      command_name "start"
      desc "Power a host on"
      success_message "The host is starting."

      def power_action
        :start
      end
    end


    class StopCommand < HammerCLI::Apipie::WriteCommand

      option '--force', :flag, "Force turning off a host"

      identifiers :id, :name
      action "power"

      command_name "stop"
      desc "Power a host off"

      def power_action
        if force?
          :cycle
        else
          :stop
        end
      end

      def success_message
        if force?
          "Power off forced."
        else
          "Powering the host off."
        end
      end
    end

    class RebootCommand < HammerCLI::Apipie::WriteCommand

      identifiers :id, :name
      action "power"

      command_name "reboot"
      desc "Reboot a host"
      success_message "Host reboot started."

      def power_action
        :soft
      end
    end

    class SCParamsCommand < HammerCLIForeman::SmartClassParametersList

      apipie_options :without => [:host_id, :hostgroup_id, :puppetclass_id, :environment_id]
      option ['--id', '--name'], 'HOST_ID', 'host id/name', 
              :attribute_name => :host_id, :required => true
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'host', "Manipulate Foreman's hosts.", HammerCLIForeman::Host
