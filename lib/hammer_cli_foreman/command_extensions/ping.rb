module HammerCLIForeman
  module CommandExtensions
    class Ping < HammerCLI::CommandExtensions
      before_print do |data|
        unless data['results']['foreman'].nil?
          status = data['results']['foreman']['database']['active']
          data['results']['foreman']['database']['active'] = status ? 'ok' : 'FAIL'
          duration = data['results']['foreman']['database']['duration_ms']
          data['results']['foreman']['database']['duration_ms'] = _("Duration: %sms") % duration
        end
      end
    end
  end
end
