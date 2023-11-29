module HammerCLIForeman
  module CommandExtensions
    class Ping < HammerCLI::CommandExtensions
      before_print do |data|
        unless data['results']['foreman'].nil?
          status = data['results']['foreman']['database']['active']
          data['results']['foreman']['database']['active'] = status ? 'ok' : 'FAIL'
          duration = data['results']['foreman']['database']['duration_ms']
          data['results']['foreman']['database']['duration_ms'] = _('Duration: %sms') % duration
          cache = data['results']['foreman']['cache']
          data['results']['foreman']['cache'] = format_cache(cache) if cache
        end
      end

      def self.format_cache(cache)
        servers = cache['servers'].map do |server|
          {
            status: server['status'],
            duration_ms: _('Duration: %sms') % server['duration_ms']
          }
        end
        {
          'servers': servers
        }
      end

      def self.check_for_unrecognized(plugins, output_definition)
        failed = plugins.select { |_, data| data['services'] }
                        .each_with_object([]) { |(_, d), s| s << d['services'] }
                        .reduce({}, :merge)
                        .select do |name, data|
          begin
            output_definition.find_field(name)
            false
          rescue ArgumentError
            data['status'] == _('FAIL')
          end
        end
        return if failed.empty?

        warn [_('%{count} more service(s) failed, but not shown:') % { count: failed.size },
              failed.keys.join(', '),
              ''].join("\n")
      end

      def self.failed?(services)
        services['foreman']['database']['active'] == 'FAIL' ||
          services.each_value.any? { |s| s['status'] == _('FAIL') }
      end

      request_options do |options|
        options[:with_authentication] = false
      end
    end
  end
end
