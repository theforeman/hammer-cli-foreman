require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class PuppetClass < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Puppetclass

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        from "puppetclass" do
          field :id, "Id"
          field :name, "Name"
        end
      end

      def retrieve_data
        self.class.unhash_classes(super)
      end

      def self.unhash_classes(classes)
        classes.inject([]) { |list, (pp_module, pp_module_classes)| list + pp_module_classes }
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      #FIXME: show environments and hostgroups
      output ListCommand.output_definition do
        from "puppetclass" do
          collection :lookup_keys, "Smart variables" do
            from :lookup_key do
              field :key, "Parameter"
              field :default_value, "Default value"
            end
          end
        end
      end

    end


    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'puppet_class', "Search Foreman's puppet modules.", HammerCLIForeman::PuppetClass

