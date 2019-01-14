module HammerCLIForeman
  module Api
    class InteractiveBasicAuth < ApipieBindings::Authenticators::BasicAuth
      def authenticate(request, args)
        if HammerCLI.interactive?
          get_user
          get_password
        end
        super
      end

      def error(ex)
        if ex.is_a?(RestClient::Unauthorized)
          self.clear
          message = _('Invalid username or password.')
          begin
            message = JSON.parse(ex.response.body)['error']['message']
          rescue
          end
          UnauthorizedError.new(message)
        end
      end

      def status
        unless @user.nil? || @password.nil?
          _("Using configured credentials for user '%s'.") % @user
        else
          _("Credentials are not configured.")
        end
      end

      def user(ask=nil)
        @user ||= ask && get_user
      end

      def password(ask=nil)
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
        @user ||= ask_user(_("[Foreman] Username:%s") % " ")
      end

      def get_password
        @password ||= ask_user(_("[Foreman] Password for %{user}:%{wsp}") % {:user => @user, :wsp => " "}, true)
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
