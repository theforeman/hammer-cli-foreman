module HammerCLIForeman
  module Api
    module BasicAuth
      def authenticate(request, args)
        if HammerCLI.interactive?
          get_user
          get_password
        end
        super
      end

      def error(ex)
        return unless ex.is_a?(RestClient::Unauthorized)

        clear
        default_message = _('Invalid username or password.')
        message = begin
          response_msg = JSON.parse(ex.response.body)['error']
          response_msg.is_a?(Hash) ? response_msg['message'] : response_msg
        rescue
        end
        return UnauthorizedError.new(default_message) unless message

        UnauthorizedError.new("#{message}\n#{default_message}")
      end

      def status
        unless @user.nil? || @password.nil?
          _("Using configured credentials for user '%s'.") % @user
        else
          _('Credentials are not configured.')
        end
      end

      def user(ask = nil)
        @user ||= ask && get_user
      end

      def password(ask = nil)
        @password ||= ask && get_password
      end

      def set_credentials(user, password)
        @user = user
        @password = password
      end

      def clear
        set_credentials(nil, nil)
      end

      private

      def get_user
        @user ||= ask_user(_('[Foreman] Username:%s') % ' ')
      end

      def get_password
        @password ||= ask_user(_("[Foreman] Password for %{user}:%{wsp}") % { user: @user, wsp: ' ' }, true)
      end

      def ask_user(prompt, silent = false)
        if silent
          HammerCLI.interactive_output.ask(prompt) { |q| q.echo = false }
        else
          HammerCLI.interactive_output.ask(prompt)
        end
      end
    end
  end
end
