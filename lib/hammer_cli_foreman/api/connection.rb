require 'hammer_cli_foreman/api/session_authenticator_wrapper'
require 'hammer_cli_foreman/api/authenticator'
require 'hammer_cli_foreman/api/interactive_basic_auth'
require 'hammer_cli_foreman/api/oauth/authentication_code_grant'
require 'hammer_cli_foreman/api/oauth/password_grant'
require 'hammer_cli_foreman/api/void_auth'
require 'uri'

module HammerCLIForeman
  CONNECTION_NAME = 'foreman'
  AUTH_TYPES = {
    basic_auth: 'Basic_Auth',
    oauth_authentication_code_grant: 'Oauth_Authentication_Code_Grant',
    oauth_password_grant: 'Oauth_Password_Grant'
  }.freeze

  module Api
    class Connection < HammerCLI::Apipie::ApiConnection
      attr_reader :authenticator

      def initialize(settings, logger = nil, locale = nil, auth_type = nil)
        auth_type ||= default_auth_type(settings)
        default_params = build_default_params(settings, logger, locale, auth_type)
        super(default_params,
          :logger => logger,
          :reload_cache => settings.get(:_params, :reload_cache) || settings.get(:reload_cache)
        )
      end

      def login
        # Call some api entry point to trigger the successful connection
        @api.resource(:home).action(:status).call
      end

      def logout
        @authenticator.clear if @authenticator.respond_to?(:clear)
      end

      def login_status
        @authenticator.status
      end

      protected

      # If the settings in foreman.yml has use_sessions as false, use :basic_auth
      # Else if the settings in foreman.yml has use_sessions as true
      # and if there exists a session_file with valid contents, we use the auth_type from sessions_file
      # Thus if the session expires (indicated by nil session_id), we use the
      # same auth_type for re-authentication as was used by the previous session.
      # Else we use the passed auth_type.
      def default_auth_type(settings)
        return AUTH_TYPES[:basic_auth] unless HammerCLIForeman::Sessions.enabled?

        url = settings.get(:_params, :host) || settings.get(:foreman, :host)
        username = settings.get(:_params, :username) || settings.get(:foreman, :username)
        session = HammerCLIForeman::Sessions.get(url)
        if !session.valid? && session.user_name == username && !session.auth_type.nil?
          session.auth_type
        else
          # If the caller has not sepcified an 'auth_type'
          # and the 'default_auth_type' in settings is also undefined
          # use :basic_auth for authentication.
          HammerCLI::Settings.get(:foreman, :default_auth_type) || AUTH_TYPES[:basic_auth]
        end
      end

      def create_authenticator(uri, settings, auth_type)
        return @authenticator if @authenticator

        @authenticator = HammerCLIForeman::Api::Authenticator.new(auth_type, uri, settings).fetch
      end

      def build_default_params(settings, logger, locale, auth_type)
        config = {}
        config[:uri] = settings.get(:_params, :host) || settings.get(:foreman, :host)
        config[:logger] = logger unless logger.nil?
        config[:api_version] = 2
        config[:follow_redirects] = settings.get(:foreman, :follow_redirects) || :never
        config[:aggressive_cache_checking] = settings.get(:foreman, :refresh_cache) || false
        unless locale.nil?
          config[:headers] = { "Accept-Language" => locale }
          config[:language] = locale
        end
        config[:timeout] = settings.get(:foreman, :request_timeout)
        config[:timeout] = -1 if (config[:timeout] && config[:timeout].to_i < 0)
        config[:apidoc_authenticated] = false
        config[:authenticator] = create_authenticator(config[:uri], settings, auth_type)
        config
      end
    end
  end

  def self.foreman_api_connection
    HammerCLI.context[:api_connection].create(CONNECTION_NAME) do
      HammerCLIForeman::Api::Connection.new(HammerCLI::Settings, Logging.logger['API'], HammerCLI::I18n.locale)
    end
  end

  def self.foreman_api_reconnect(auth_type)
    HammerCLI.context[:api_connection].drop(CONNECTION_NAME)
    HammerCLI.context[:api_connection].create(CONNECTION_NAME) do
      HammerCLIForeman::Api::Connection.new(
        HammerCLI::Settings,
        Logging.logger['API'],
        HammerCLI::I18n.locale,
        auth_type)
    end
  end

  def self.init_api_connection
    foreman_api_connection
  end
end
