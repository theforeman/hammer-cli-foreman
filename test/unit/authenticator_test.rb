require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLIForeman::Api::Authenticator do
  let(:uri) { 'https://foreman.example.com' }
  let(:settings) { HammerCLI::Settings }

  describe '#initialize' do
    it 'initializes the values' do
      auth_type = HammerCLIForeman::AUTH_TYPES[:oauth_password_grant]
      authenticator = HammerCLIForeman::Api::Authenticator.new(auth_type, uri, settings)
      assert_equal authenticator.auth_type, auth_type
      assert_equal authenticator.uri, uri
      assert_equal authenticator.settings, settings
    end
  end

  describe '#fetch' do
    context 'when sessions are disabled' do

      it 'must take default values from foreman config file and set them to authenticator' do
        HammerCLI::Settings.load({ :foreman => { :username => 'admin', :password => 'changeme'} })
        auth_type = HammerCLIForeman::AUTH_TYPES[:basic_auth]
        authenticator = HammerCLIForeman::Api::Authenticator.new(auth_type, uri, settings).fetch
        assert_equal authenticator.user, settings.get(:foreman, :username)
        assert_equal authenticator.password, settings.get(:foreman, :password)
      end

      it 'must fail to login with oauth with password grant' do
        auth_type = HammerCLIForeman::AUTH_TYPES[:oauth_password_grant]
        authenticator = HammerCLIForeman::Api::Authenticator.new(auth_type, uri, settings).fetch
        assert_nil authenticator
      end

      it 'must fail to login with oauth with code grant' do
        auth_type = HammerCLIForeman::AUTH_TYPES[:oauth_authentication_code_grant]
        authenticator = HammerCLIForeman::Api::Authenticator.new(auth_type, uri, settings).fetch
        assert_nil authenticator
      end
    end

    context 'when sessions are enabled' do
      before do
        HammerCLI::Settings.load({ :foreman => { :use_sessions => true } })
      end

      it 'must ask for values from the user interactively to perform login' do
        auth_type = HammerCLIForeman::AUTH_TYPES[:basic_auth]
        authenticator = HammerCLIForeman::Api::Authenticator.new(auth_type, uri, settings).fetch
        assert_equal authenticator.auth_type, auth_type
      end

      it 'must perform login with oauth with password grant' do
        auth_type = HammerCLIForeman::AUTH_TYPES[:oauth_password_grant]
        authenticator = HammerCLIForeman::Api::Authenticator.new(auth_type, uri, settings).fetch
        assert_equal authenticator.auth_type, auth_type
      end

      it 'must perform login with oauth with code grant' do
        auth_type = HammerCLIForeman::AUTH_TYPES[:oauth_authentication_code_grant]
        authenticator = HammerCLIForeman::Api::Authenticator.new(auth_type, uri, settings).fetch
        assert_equal authenticator.auth_type, auth_type
      end
    end
  end
end