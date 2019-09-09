module HammerCLIForeman
  class StatusCommand < HammerCLIForeman::Command
    resource :ping

    class ForemanCommand < HammerCLIForeman::Command
      action :statuses
      command_name 'foreman'

      output do
        from 'foreman' do
          field :version, _('Version')
          from 'api' do
            field :version, _('API Version')
          end
          field :database, _('Database'), Fields::Label do
            field :active, _('Status')
            field :duration_ms, _('Server Response')
          end
          collection :plugins, _('Plugins') do
            field :name, _('Name')
            field :version, _('Version')
          end
          collection :smart_proxies, _('Smart Proxies') do
            field :name, _('Name')
            field :version, _('Version')
            field :status, _('Status')
            collection :features, _('Features'), hide_blank: true do
              field :name, _('Name')
              field :version, _('Version')
            end
            collection :failed_features, _('Failed features'), hide_blank: true do
              field :name, _('Name')
              field :error, _('Error')
            end
          end
          collection :compute_resources, _('Compute Resources') do
            field :name, _('Name')
            field :status, _('Status')
            collection :errors, _('Errors'), hide_blank: true do
              field nil, nil
            end
          end
        end
      end

      extend_with(HammerCLIForeman::CommandExtensions::Ping.new(only: :data))
      extend_with(HammerCLIForeman::CommandExtensions::Status.new(only: :data))
    end

    self.default_subcommand = 'foreman'
    autoload_subcommands
  end
end
