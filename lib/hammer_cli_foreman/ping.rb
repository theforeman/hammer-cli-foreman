module HammerCLIForeman
  class PingCommand < HammerCLIForeman::Command
    resource :ping

    class ForemanCommand < HammerCLIForeman::Command
      action :ping
      command_name 'foreman'

      output do
        from 'foreman' do
          field :database, _('database'), Fields::Label do
            field :active, _('Status')
            field :duration_ms, _('Server Response')
          end
          field :cache, _('cache'), Fields::Label do
            field :servers, _('servers'), Fields::Collection do
              field :status, _('Status')
              field :duration_ms, _('Server Response')
            end
          end
        end
      end

      def execute
        response = send_request
        print_data(response)

        if HammerCLIForeman::CommandExtensions::Ping.failed?(response)
          HammerCLIForeman::CommandExtensions::Ping.check_for_unrecognized(
            response, output_definition
          )
          return 1
        end

        HammerCLI::EX_OK
      end

      extend_with(HammerCLIForeman::CommandExtensions::Ping.new)
    end

    self.default_subcommand = 'foreman'
    autoload_subcommands
  end
end
