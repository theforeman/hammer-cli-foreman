require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/parameter'

module HammerCLIForeman

  class Host < HammerCLI::AbstractCommand
    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::Host, "index"

      heading "Host list"
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

      resource ForemanApi::Resources::Host, "show"

      def retrieve_data
        host = super
        host["host"]["environment_name"] = host["host"]["environment"]["environment"]["name"] rescue nil
        host["parameters"] = HammerCLIForeman::Parameter.get_parameters resource_config, host
        host
      end

      heading "Host info"
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

          field :created_at, "Created at", HammerCLI::Output::Fields::Date
          field :updated_at, "Updated at", HammerCLI::Output::Fields::Date
          field :installed_at, "Installed at", HammerCLI::Output::Fields::Date
          field :last_report, "Last report", HammerCLI::Output::Fields::Date

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
          field :parameter, nil, HammerCLI::Output::Fields::KeyValue
        end
      end
    end


    class StatusCommand < HammerCLIForeman::InfoCommand

      command_name "status"
      resource ForemanApi::Resources::Host, "status"

      def print_data(records)
        output.print_message records["status"]
      end
    end


    class PuppetRunCommand < HammerCLIForeman::InfoCommand

      command_name "puppetrun"
      resource ForemanApi::Resources::Host, "puppetrun"

      def print_data(records)
        output.print_message 'Puppet run triggered'
      end
    end


    class FactsCommand < HammerCLIForeman::ListCommand

      command_name "facts"
      resource ForemanApi::Resources::FactValue, "index"
      identifiers :name

      apipie_options

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

      def self.apipie_options(options={})
        super(options.merge(:without => declared_identifiers.keys))
      end

      def retrieve_data
        data = super
        host = data.keys[0]
        new_data = data[host].keys.map { |f| { :fact => { :fact => f, :value => data[host][f] } } }
        new_data
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Host created"
      failure_message "Could not create the host"
      resource ForemanApi::Resources::Host, "create"

      apipie_options :without => ['host_parameters_attributes']

      #FIXME with following setup it is possible to create hosts with the default network setup
      # needs create redesign
      def request_params
        params = super
        params['host']['compute_attributes']["nics_attributes"] = {
          "new_nics"=>{"type"=>"bridge", "_delete"=>"", "bridge"=>""},
          "0"=>{"type"=>"network", "_delete"=>"", "network"=>"default", "bridge"=>""}
        }
        params
      end
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      success_message "Host updated"
      failure_message "Could not update the host"
      resource ForemanApi::Resources::Host, "update"

      apipie_options :without => ['host_parameters_attributes', 'name', 'id']
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      success_message "Host deleted"
      failure_message "Could not delete the host"
      resource ForemanApi::Resources::Host, "destroy"

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

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'host', "Manipulate Foreman's hosts.", HammerCLIForeman::Host

