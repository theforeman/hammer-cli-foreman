require 'hammer_cli_foreman/smart_class_parameter'

module HammerCLIForeman

  class PuppetClass < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Puppetclass

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, "Id"
        field :name, "Name"
      end

      def retrieve_data
        self.class.unhash_classes(super)
      end

      def self.unhash_classes(classes)
        clss = classes.first.inject([]) { |list, (pp_module, pp_module_classes)| list + pp_module_classes }

        HammerCLI::Output::RecordCollection.new(clss, :meta => classes.meta)

      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      #FIXME: show environments, hostgroups, variables and parameters
      output ListCommand.output_definition do
        collection :lookup_keys, "Smart variables" do
          from :lookup_key do
            field :key, "Parameter"
            field :default_value, "Default value"
          end
        end
      end

      apipie_options
    end


    class SCParamsCommand < HammerCLIForeman::SmartClassParametersBriefList

      apipie_options :without => [:host_id, :hostgroup_id, :puppetclass_id, :environment_id]
      option ['--id', '--name'], 'PUPPET_CLASS_ID', 'puppet class id/name',
              :attribute_name => :puppetclass_id, :required => true
    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'puppet_class', "Search puppet modules.", HammerCLIForeman::PuppetClass

