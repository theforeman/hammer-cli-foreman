require 'hammer_cli_foreman/api/session_authenticator_wrapper'
require 'hammer_cli_foreman/api/interactive_basic_auth'

module HammerCLIForeman
  module Api
    class Connection < HammerCLI::Apipie::ApiConnection
      attr_reader :authenticator

      def initialize(settings, logger = nil, locale = nil)
        default_params = build_default_params(settings, logger, locale)
        super(default_params,
          :logger => logger,
          :reload_cache => settings.get(:_params, :reload_cache) || settings.get(:reload_cache)
        )
      end

      def login
        # Call some api entry point to trigger the
        @api.resource(:home).action(:status).call
      end

      def logout
        @authenticator.clear if @authenticator.respond_to?(:clear)
      end

      def login_status
        @authenticator.status
      end

      protected

      def create_authenticator(uri, settings)
        return @authenticator unless @authenticator.nil?

        @authenticator = InteractiveBasicAuth.new(
          settings.get(:_params, :username) || ENV['FOREMAN_USERNAME'] || settings.get(:foreman, :username),
          settings.get(:_params, :password) || ENV['FOREMAN_PASSWORD'] || settings.get(:foreman, :password)
        )
        @authenticator = SessionAuthenticatorWrapper.new(@authenticator, uri) if settings.get(:foreman, :use_sessions)
        @authenticator
      end

      def build_default_params(settings, logger, locale)
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
        config[:authenticator] = create_authenticator(config[:uri], settings)
        config
      end
    end
  end

  CONNECTION_NAME = 'foreman'

  def self.foreman_api_connection
    HammerCLI.context[:api_connection].create(CONNECTION_NAME) do
      HammerCLIForeman::Api::Connection.new(HammerCLI::Settings, Logging.logger['API'], HammerCLI::I18n.locale)
    end
  end

  def self.init_api_connection
    foreman_api_connection
  end
end

