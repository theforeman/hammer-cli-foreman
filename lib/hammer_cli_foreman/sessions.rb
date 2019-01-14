require 'uri'
module HammerCLIForeman
  class Sessions

    STORAGE_DIR = File.expand_path('~/.hammer/sessions/')

    def self.get(url)
      raise _('Sessions are not enabled, please check your Hammer settings.') unless enabled?

      unless File.exist?(storage)
        FileUtils.mkdir_p(storage, mode: 0700)
      end
      unless configured?(url)
        warn _('Using session auth with invalid permissions on session files is not recommended.')
      end
      HammerCLIForeman::Session.new(session_file(url))
    end

    def self.storage
      STORAGE_DIR
    end

    def self.enabled?
      HammerCLI::Settings.get(:foreman, :use_sessions)
    end

    def self.session_file(url)
      raise _('The url is empty. Session can not be created.') if url.nil? || url.empty?

      uri = URI.parse(url)
      File.join(storage, "#{uri.scheme}_#{uri.host}")
    rescue URI::InvalidURIError
      raise _('The url (%s) is not a valid URL. Session can not be created.') % url
    end

    def self.configured?(url)
      ensure_mode(storage, '40700') && ensure_mode(session_file(url), '100600')
    end

    def self.ensure_mode(file, expected_mode)
      return true unless File.exist?(file)

      mode = File.stat(file).mode.to_s(8)
      if mode != expected_mode
        warn _("Invalid permissions for %{file}: %{mode}, expected %{expected_mode}.") % {
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

  class Session
    attr_accessor :id, :user_name, :auth_type

    def initialize(session_path)
      @session_path = File.expand_path(session_path)
      if File.exist?(@session_path) && !File.zero?(@session_path)
        session_data = JSON.parse(File.read(@session_path))
        @id = session_data['id']
        @user_name = session_data['user_name']
        @auth_type = session_data['auth_type']
      end
    rescue JSON::ParserError
      warn _('Invalid session data. Resetting the session.')
    end

    def store
      File.open(@session_path,"w") do |f|
        f.write({
          id: id,
          auth_type: auth_type,
          user_name: user_name
        }.to_json)
      end
      File.chmod(0600, @session_path)
    end

    def destroy
      @id = nil
      store
    end

    def valid?
      !id.nil? && !id.empty?
    end
  end
end