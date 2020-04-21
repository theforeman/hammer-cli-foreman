require 'jwt'
require 'hammer_cli_foreman/openid_connect'

module HammerCLIForeman
  module Api
    module Oauth
      class AuthenticationCodeGrant < ApipieBindings::Authenticators::TokenAuth
        attr_accessor :oidc_token_endpoint, :oidc_authorization_endpoint, :oidc_client_id, :token, :oidc_redirect_uri, :token_expires_at

        def initialize(oidc_token_endpoint, oidc_authorization_endpoint, oidc_client_id, oidc_redirect_uri)
          @oidc_token_endpoint = oidc_token_endpoint
          @oidc_authorization_endpoint = oidc_authorization_endpoint
          @oidc_client_id = oidc_client_id
          @oidc_redirect_uri = oidc_redirect_uri
          set_token_details(oidc_token_endpoint, oidc_authorization_endpoint, oidc_client_id, oidc_redirect_uri)
          super(@token)
        end

        def authenticate(request, token)
          if HammerCLI.interactive?
            set_token_details_interactively
          end
          super
        end

        def set_token_details_interactively
          return unless @token.nil?
          @token ||= set_token_details(get_oidc_token_endpoint, get_oidc_authorization_endpoint, get_oidc_client_id, get_oidc_redirect_uri)
        end

        def set_token_details(input_oidc_token_endpoint, input_oidc_authorization_endpoint, input_oidc_client_id, input_oidc_redirect_uri)
          @oidc_token_endpoint = input_oidc_token_endpoint if input_oidc_token_endpoint
          @oidc_authorization_endpoint = input_oidc_authorization_endpoint if input_oidc_authorization_endpoint
          @oidc_client_id = input_oidc_client_id if input_oidc_client_id
          @oidc_redirect_uri = input_oidc_redirect_uri if input_oidc_redirect_uri

          if @oidc_client_id.to_s.empty? || @oidc_authorization_endpoint.to_s.empty? || @oidc_redirect_uri.to_s.empty? || @oidc_token_endpoint.to_s.empty?
            @token_expires_at = nil
            @token = nil
          else
            get_code
            token_details = HammerCLIForeman::OpenidConnect.new(
              @oidc_token_endpoint, @oidc_client_id).token_details_via_2fa(@code, @oidc_redirect_uri)
            @token_expires_at = Time.now.utc + token_details['expires_in']
            @token = token_details['access_token']
          end
        end

        def user
          return nil unless @token
          payload = JWT.decode(@token, nil, false)
          payload.first["preferred_username"]
        end

        def error(ex)
          if ex.is_a?(RestClient::InternalServerError)
            @oidc_token_endpoint = @oidc_authorization_endpoint = @oidc_client_id = @oidc_client_id = nil
            original_message = _("Invalid oidc-client-id or oidc-token-endpoint or oidc-authorization-endpoint.\n")
            begin
              message = JSON.parse(ex.response.body)['error']['message']
            rescue
            end
            UnauthorizedError.new(original_message << message)
          end
        end

        private

        def get_code
          @token_url = "#{@oidc_authorization_endpoint}?"\
                        'response_type=code'\
                        "&client_id=#{@oidc_client_id}"\
                        "&redirect_uri=#{@oidc_redirect_uri}"\
                        '&scope=openid'
          HammerCLI.interactive_output.say("Enter URL in browser: #{@token_url}")
          @code ||= ask_user(_("Code:%s") % " ")
        end

        def get_oidc_authorization_endpoint
          @oidc_authorization_endpoint ||= ask_user(_("Openidc Provider Authorization Endpoint:%s") % " ")
        end

        def get_oidc_token_endpoint
          @oidc_token_endpoint ||= ask_user(_("Openidc Provider Token Endpoint:%s") % " ")
        end

        def get_oidc_client_id
          @oidc_client_id ||= ask_user(_("Client ID:%s") % " ")
        end

        def get_oidc_redirect_uri
          @oidc_redirect_uri ||= ask_user(_("Redirect URI:%s") % " ")
        end

        def ask_user(prompt, silent=false)
          if silent
            HammerCLI.interactive_output.ask(prompt) { |q| q.echo = false }
          else
            HammerCLI.interactive_output.ask(prompt)
          end
        end
      end
    end
  end
end
