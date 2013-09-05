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
        self.class.unhash_facts(super)
      end

      def self.unhash_facts(facts_hash)
        facts_hash.inject([]) do |list, (host, facts)|
          list + facts.collect do |(fact, value)|
            { :fact => { :host => host, :fact => fact, :value => value } }
          end
        end
      end

    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'fact', "Search Foreman's facts.", HammerCLIForeman::Fact
