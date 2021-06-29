module HammerCLIForeman
  module Api
    class NegotiateAuth < ApipieBindings::Authenticators::Negotiate
      def initialize(foreman_url, **options)
        super("#{foreman_url}/users/extlogin", HammerCLI::SSLOptions.new.get_options(foreman_url).merge(options))
      end

      def user
        'UNKNOWN'
      end
    end
  end
end
