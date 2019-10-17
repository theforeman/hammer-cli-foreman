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
          end
        end

        extend_with(HammerCLIForeman::CommandExtensions::Ping.new)
      end

    self.default_subcommand = 'foreman'
    autoload_subcommands
  end
end
