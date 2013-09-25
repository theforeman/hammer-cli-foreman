require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/parameter'

module HammerCLIForeman

  class Hostgroup < HammerCLI::AbstractCommand
    class ListCommand < HammerCLIForeman::ListCommand
      resource ForemanApi::Resources::Hostgroup, "index"

      output do
        from "hostgroup" do
          field :id, "Id"
          field :name, "Name"
          field :label, "Label"
          field :operatingsystem_id, "Operating System Id"
          field :subnet_id, "Subnet Id"
          field :domain_id, "Domain Id"
          field :environment_id, "Environment Id"
          field :puppetclass_ids, "Puppetclass Ids", Fields::List
          field :ancestry, "Ancestry"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      resource ForemanApi::Resources::Hostgroup, "show"

      identifiers :id

      output ListCommand.output_definition do
        collection :parameters, "Parameters" do
          field :parameter, nil, Fields::KeyValue
        end
      end

      def retrieve_data
        hostgroup = super
        hostgroup["parameters"] = HammerCLIForeman::Parameter.get_parameters resource_config, hostgroup
        hostgroup
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand

      success_message "Hostgroup created"
      failure_message "Could not create the hostgroup"
      resource ForemanApi::Resources::Hostgroup, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand

      identifiers :id

      success_message "Hostgroup updated"
      failure_message "Could not update the hostgroup"
      resource ForemanApi::Resources::Hostgroup, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand

      identifiers :id

      success_message "Hostgroup deleted"
      failure_message "Could not delete the hostgroup"
      resource ForemanApi::Resources::Hostgroup, "destroy"

      apipie_options
    end


    class PuppetClassesCommand < HammerCLIForeman::ListCommand

      command_name "puppet_classes"
      resource ForemanApi::Resources::Puppetclass

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

      desc "Create or update parameter for a hostgroup."

      option "--hostgroup-id", "HOSTGROUP_ID", "id of the hostgroup the parameter is being set for", :required => true

      success_message_for :update, "Hostgroup parameter updated"
      success_message_for :create, "New hostgroup parameter created"
      failure_message "Could not set hostgroup parameter"

      def base_action_params
        {
          "hostgroup_id" => hostgroup_id
        }
      end
    end


    class DeleteParameterCommand < HammerCLIForeman::Parameter::DeleteCommand

      desc "Delete parameter for a hostgroup."

      option "--hostgroup-id", "HOSTGROUP_ID", "id of the hostgroup the parameter is being deleted for", :required => true

      success_message "Hostgroup parameter deleted"

      def base_action_params
        {
          "hostgroup_id" => hostgroup_id
        }
      end
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'hostgroup', "Manipulate Foreman's hostgroups.", HammerCLIForeman::Hostgroup

