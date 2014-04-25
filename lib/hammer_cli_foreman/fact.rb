module HammerCLIForeman

  class Fact < HammerCLI::AbstractCommand

    class ListCommand < HammerCLIForeman::ListCommand

      resource :fact_values, :index

      build_options

      output do
        field :host, _("Host")
        field :fact, _("Fact")
        field :value, _("Value")
      end

      def send_request
        self.class.unhash_facts(super)
      end

      def self.unhash_facts(facts_collection)
        facts = facts_collection.first.inject([]) do |list, (host, facts)|
          list + facts.collect do |(fact, value)|
            { :host => host, :fact => fact, :value => value }
          end
        end
        HammerCLI::Output::RecordCollection.new(facts, :meta => facts_collection.meta)
      end
    end

    autoload_subcommands
  end

end

HammerCLI::MainCommand.subcommand 'fact', _("Search facts."), HammerCLIForeman::Fact
