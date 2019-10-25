require 'uri'

module HammerCLIForeman
  module Api
    class SessionAuthenticatorWrapper < ApipieBindings::Authenticators::Base

      attr_reader :session_id, :url, :auth_type

      def initialize(authenticator, url, auth_type)
        @authenticator = authenticator
        @url = url
        @auth_type = auth_type
      end

      def session
        @session ||= Sessions.get(@url)
      end

      def clear
        session.destroy
        @authenticator.clear if @authenticator.respond_to?(:clear)
      end

      def status
        if session.valid?
          _("Session exists, currently logged in as '%s'.") % session.user_name
        else
          _('Using sessions, you are currently not logged in.')
        end
      end

      def force_user_change
        @user_changed = true
      end

      def user_changed?
        !!@user_changed
      end

      def authenticate(request, args)
        user = @authenticator.user

        @user_changed ||= (!user.nil? && user != session.user_name)

        if !@user_changed && Sessions.configured?(@url) && session.id
          jar = HTTP::CookieJar.new
          jar.add(HTTP::Cookie.new('_session_id', session.id, domain: uri.hostname.downcase, path: '/', for_domain: true))
          request['Cookie'] = HTTP::Cookie.cookie_value(jar.cookies)
          request
        else
          @authenticator.authenticate(request, args)
        end
      end

      def error(ex)
        if ex.is_a?(RestClient::Unauthorized) && session.valid?
          if @user_changed
            return UnauthorizedError.new(_("Invalid username or password, continuing with session for '%s'.") % session.user_name)
          else
            session.destroy
            return SessionExpired.new(_("Session has expired."))
          end
        else
          return @authenticator.error(ex)
        end
      end

      def response(r)
        if (r.cookies['_session_id'] && r.code != 401)
          session.id = r.cookies['_session_id']
          session.user_name = @authenticator.user
          session.auth_type = @auth_type
          session.store
        end
        @authenticator.response(r)
      end

      def user(ask=nil)
        return unless @authenticator.respond_to?(:user)
        if @auth_type == AUTH_TYPES[:basic_auth]
          @authenticator.user(ask)
        elsif @auth_type == AUTH_TYPES[:oauth_authentication_code_grant] ||
              @auth_type = AUTH_TYPES[:oauth_password_grant]
          @authenticator.user
        end
      end

      def password(ask=nil)
        @authenticator.password(ask) if @authenticator.respond_to?(:password)
      end

      def set_auth_params(*args)
        if @auth_type == AUTH_TYPES[:basic_auth]
          @authenticator.set_credentials(*args)
        elsif @auth_type == AUTH_TYPES[:oauth_authentication_code_grant] ||
              @auth_type == AUTH_TYPES[:oauth_password_grant]
          @authenticator.set_token(*args)
        end
      end

      def uri
        @uri ||= URI.parse(@url)
      end
    end
  end
end
