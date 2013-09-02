require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class Fact < HammerCLI::AbstractCommand

    class ListCommand < HammerCLIForeman::ListCommand

      resource ForemanApi::Resources::FactValue, "index"

      apipie_options

      output do
        from "fact" do
          field :host, "Host"
          field :fact, "Fact"
          field :value, "Value"
        end
      end

      def retrieve_data
        data = super
        new_data = data.keys.map do |host|
          data[host].keys.map do |f|
            { :fact => { :host => host, :fact => f, :value => data[host][f] } }
          end
        end
        new_data.flatten(1)
      end
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'fact', "Search Foreman's facts.", HammerCLIForeman::Fact
