require 'hammer_cli_foreman/openid_connect'

module HammerCLIForeman
  module Api
    module Oauth
      class PasswordGrant < ApipieBindings::Authenticators::TokenAuth
        attr_accessor :oidc_token_endpoint, :oidc_client_id, :user, :password, :token

        def initialize(oidc_token_endpoint, oidc_client_id, user, password)
          @oidc_token_endpoint = oidc_token_endpoint
          @oidc_client_id = oidc_client_id
          @user = user
          @password = password
          super set_token(oidc_token_endpoint, oidc_client_id, user, password)
        end

        def authenticate(request, token)
          if HammerCLI.interactive?
            set_token_interactively
          end
          super
        end

        def set_token_interactively
          @token ||= set_token(get_oidc_token_endpoint, get_oidc_client_id, get_user, get_password)
        end

        def set_token(input_oidc_token_endpoint, input_oidc_client_id, input_user, input_password)
          @oidc_token_endpoint = input_oidc_token_endpoint if input_oidc_token_endpoint
          @user = input_user
          @password = input_password
          @oidc_client_id = input_oidc_client_id if input_oidc_client_id
          if @user.to_s.empty? || @password.to_s.empty? || @oidc_token_endpoint.to_s.empty? || @oidc_client_id.to_s.empty?
            @token = nil
          else
            @token = HammerCLIForeman::OpenidConnect.new(
              @oidc_token_endpoint, @oidc_client_id).get_token(@user, @password)
          end
        end

        def error(ex)
          if ex.is_a?(RestClient::InternalServerError)
            @user = @password = @oidc_token_endpoint = @oidc_client_id = nil
            original_message = _("Invalid credentials or oidc-client-id or oidc-token-endpoint.\n")
            begin
              message = JSON.parse(ex.response.body)['error']['message']
            rescue
            end
            UnauthorizedError.new(original_message << message)
          end
        end

        private

        def get_user
          @user ||= ask_user(_("Username:%s") % " ")
        end

        def get_password
          @password ||= ask_user(_("Password:%{wsp}") % {:wsp => " "}, true)
        end

        def get_oidc_token_endpoint
          @oidc_token_endpoint ||= ask_user(_("Openidc Provider Token Endpoint:%s") % " ")
        end

        def get_oidc_client_id
          @oidc_client_id ||= ask_user(_("Client ID:%s") % " ")
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
