module HammerCLIForeman
  module Api
    class Authenticator
      attr_accessor :auth_type, :uri, :settings
      def initialize(auth_type, uri, settings)
        @auth_type = auth_type
        @uri = uri
        @settings = settings
      end

      def fetch
        if ssl_cert_authentication? && !use_basic_auth?
          void_auth
        elsif auth_type == AUTH_TYPES[:basic_auth]
          basic_auth
        elsif auth_type == AUTH_TYPES[:oauth_password_grant]
          oauth_password_grant
        elsif auth_type == AUTH_TYPES[:oauth_authentication_code_grant]
          oauth_authentication_code_grant
        end
      end

      private

      def void_auth
        VoidAuth.new(_('Using certificate authentication.'))
      end

      def basic_auth
        if HammerCLIForeman::Sessions.enabled?
          authenticator = InteractiveBasicAuth.new(
            settings.get(:_params, :username) || ENV['FOREMAN_USERNAME'],
            settings.get(:_params, :password) || ENV['FOREMAN_PASSWORD']
          )
          SessionAuthenticatorWrapper.new(authenticator, uri, auth_type)
        else
          username = settings.get(:_params, :username) || ENV['FOREMAN_USERNAME'] || settings.get(:foreman, :username)
          password = settings.get(:_params, :password) || ENV['FOREMAN_PASSWORD']
          if password.nil? && (username == settings.get(:foreman, :username))
            password = settings.get(:foreman, :password)
          end
          InteractiveBasicAuth.new(username, password)
        end
      end

      def oauth_password_grant
        return unless HammerCLIForeman::Sessions.enabled?

        authenticator = Oauth::PasswordGrant.new(
          ENV['OIDC_TOKEN_ENDPOINT'] || settings.get(:foreman, :oidc_token_endpoint),
          ENV['OIDC_CLIENT_ID'] || settings.get(:foreman, :oidc_client_id),
          ENV['OIDC_USERNAME'],
          ENV['OIDC_PASSWORD']
        )
        SessionAuthenticatorWrapper.new(authenticator, uri, auth_type)
      end

      def oauth_authentication_code_grant
        return unless HammerCLIForeman::Sessions.enabled?

        authenticator = Oauth::AuthenticationCodeGrant.new(
          ENV['OIDC_TOKEN_ENDPOINT'] || settings.get(:foreman, :oidc_token_endpoint),
          ENV['OIDC_AUTHORIZATION_URL'] || settings.get(:foreman, :oidc_authorization_endpoint),
          ENV['OIDC_CLIENT_ID'] || settings.get(:foreman, :oidc_client_id),
          ENV['OIDC_REDIRECT_URI'] || settings.get(:foreman, :oidc_redirect_uri)
        )
        SessionAuthenticatorWrapper.new(authenticator, uri, auth_type)
      end

      def ssl_cert_authentication?
        (settings.get(:_params, :ssl_client_cert) || settings.get(:ssl, :ssl_client_cert)) &&
          (settings.get(:_params, :ssl_client_key) || settings.get(:ssl, :ssl_client_key))
      end

      def use_basic_auth?
        settings.get(:_params, :ssl_with_basic_auth) ||
          settings.get(:ssl, :ssl_with_basic_auth)
      end
    end
  end
end
