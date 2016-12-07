require 'uri'

module HammerCLIForeman
  module Api
    class SessionAuthenticatorWrapper < ApipieBindings::Authenticators::Base
      SESSION_STORAGE = '~/.hammer/sessions/'

      def initialize(authenticator, url, storage_dir = nil)
        @authenticator = authenticator
        @url = url

        uri = URI.parse(url)
        @session_file = "#{uri.scheme}_#{uri.host}"
        @storage_dir = storage_dir || File.expand_path(SESSION_STORAGE)

        @permissions_ok = check_storage_permissions
        warn _("Can't use session auth due to invalid permissions on session files.") unless @permissions_ok
      end

      def clear
        destroy_session
      end

      def status
        if load_session
          _("Session exist")
        else
          _("You are currently not logged in")
        end
      end


      def authenticate(request, args)
        @session_id ||= load_session

        if @permissions_ok && @session_id
          jar = HTTP::CookieJar.new
          jar.add(HTTP::Cookie.new('_session_id', @session_id, domain: request.uri.hostname.downcase, path: '/', for_domain: true))
          request['Cookie'] = HTTP::Cookie.cookie_value(jar.cookies)
          request
        else
          @authenticator.authenticate(request, args)
        end
      end

      def error(ex)
        @session_id ||= load_session
        if ex.is_a?(RestClient::Unauthorized) && !@session_id.nil?
          @session_id = nil
          destroy_session
          ex.message = _("Session has expired")
        else
          @authenticator.error(ex)
        end
      end

      def response(r)
        @session_id = r.cookies['_session_id']
        if (@session_id && r.code != 401)
          save_session(@session_id)
        end
        @authenticator.response(r)
      end

      protected

      def session_storage
        "#{@storage_dir}/#{@session_file}"
      end

      def load_session
        if File.exist?(session_storage)
          File.read(session_storage)
        end
      end

      def save_session(session_id)
        File.open(session_storage, 'w', 0600) do |f|
          f.write(session_id)
        end
      end

      def destroy_session
        File.delete(session_storage) if File.exist?(session_storage)
      end

      def check_storage_permissions
        Dir.mkdir(@storage_dir, 0700) unless File.exist?(@storage_dir)
        ensure_mode(@storage_dir, '40700') && ensure_mode(session_storage, '100600')
      end

      def ensure_mode(file, expected_mode)
        return true unless File.exist?(file)
        mode = File.stat(file).mode.to_s(8)
        if mode != expected_mode
          warn _("Invalid permissions for %{file}: %{mode}, expected %{expected_mode}") % {
            :mode => mode,
            :expected_mode => expected_mode,
            :file => file
          }
          false
        else
          true
        end
      end

    end
  end
end

