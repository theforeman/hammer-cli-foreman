require 'highline/import'

module HammerCLIForeman
  module Api
    class InteractiveBasicAuth < ApipieBindings::Authenticators::BasicAuth
      def authenticate(request, args)
        if HammerCLI.interactive?
          @user ||= ask_user(_("[Foreman] Username: "))
          @password ||= ask_user(_("[Foreman] Password for %s: ") % @user, true)
        end
        super
      end

      def error(ex)
        ex.message = _("Invalid username or password")
      end

      private

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
