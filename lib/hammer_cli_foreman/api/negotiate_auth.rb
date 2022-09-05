module HammerCLIForeman
  module Api
    class NegotiateAuth < ApipieBindings::Authenticators::Negotiate
      def initialize(foreman_url, **options)
        super("#{foreman_url}/api/users/extlogin", HammerCLI::SSLOptions.new.get_options(foreman_url).merge(options))
      end

      def user
        _('current Kerberos user')
      end

      def session_id
        auth_cookie&.delete_prefix('_session_id=')
      end

      def status
        if system('klist')
          _('No session, but there is an active Kerberos session, that will be used for negotiate login.')
        else
          _('There is no active Kerberos session. Have you run %s?') % 'kinit'
        end
      end

      def error(ex)
        super unless ex.is_a?(RestClient::Unauthorized)

        message = _('Invalid username or password.')
        begin
          message = JSON.parse(ex.response.body)['error']['message']
        rescue
        end
        UnauthorizedError.new(message)
      end
    end
  end
end
