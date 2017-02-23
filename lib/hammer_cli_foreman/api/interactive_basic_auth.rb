require 'highline/import'

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
        ex.message = _("Invalid username or password") if ex.is_a?(RestClient::Unauthorized)
      end

      def status
        unless @user.nil? || @password.nil?
          _("You are logged in as '%s'") % @user
        else
          _("You are currently not logged in")
        end
      end

      def user
        @user
      end

      private

      def get_user
        @user ||= ask_user(_("[Foreman] Username: "))
      end

      def get_password
        @password ||= ask_user(_("[Foreman] Password for %s: ") % @user, true)
      end

      def ask_user(prompt, silent=false)
        if silent
          ask(prompt) {|q| q.echo = false}
        else
          ask(prompt)
        end
      end
    end
  end
end
