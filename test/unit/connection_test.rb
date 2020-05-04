require File.join(File.dirname(__FILE__), '../test_helper')
require 'tmpdir'
require 'tempfile'

describe HammerCLIForeman::Api::Connection do
  describe '#initialize' do
    let(:oauth) { HammerCLIForeman::AUTH_TYPES[:oauth_password_grant] }
    let(:basic_auth) { HammerCLIForeman::AUTH_TYPES[:basic_auth] }

    before do
      HammerCLI::Settings.load({ :foreman => { :host => "https://foreman.example.com" } })
      HammerCLIForeman::Api::Oauth::PasswordGrant.any_instance.stubs(:new)
        .returns(HammerCLIForeman::Api::Oauth::PasswordGrant.new(nil, nil, nil, nil))
    end

    context 'when auth_type is present' do
      it 'uses the given auth_type for authentication' do
        HammerCLI::Settings.load({ :foreman => { :use_sessions => true } })
        oauth_conn = HammerCLIForeman::Api::Connection.new(HammerCLI::Settings, nil, nil, oauth)
        assert_equal oauth_conn.authenticator.auth_type, oauth

        basic_conn = HammerCLIForeman::Api::Connection.new(HammerCLI::Settings, nil, nil, basic_auth)
        assert_equal basic_conn.authenticator.auth_type, basic_auth
      end
    end

    context 'when auth_type is nil' do
      let(:subject) { HammerCLIForeman::Api::Connection.new(HammerCLI::Settings, nil, nil, nil) }

      context 'when use_sessions setting is disabled' do
        before do
          HammerCLI::Settings.load({ :foreman => { :use_sessions => false } })
        end
        it 'uses basic_auth for connection' do
          assert_equal subject.authenticator.class, HammerCLIForeman::Api::InteractiveBasicAuth
        end
      end

      context 'when use_sessions setting is enabled' do
        before do
          HammerCLI::Settings.load({ :foreman => { :use_sessions => true } })
        end

        it 'uses default_auth_type from settings for connection' do
          HammerCLI::Settings.load({ :foreman => { :default_auth_type => oauth } })
          assert_equal subject.authenticator.auth_type, oauth
        end

        it 'uses basic_auth for connection when default_auth_type is not defined in settings' do
          HammerCLI::Settings.load({ :foreman => { :default_auth_type => nil } })
          assert_equal subject.authenticator.auth_type, basic_auth
        end

        context 'when there exist a expired session' do
          it 'uses auth_type from the previous session when connecting' do
            Dir.mktmpdir do |dir|
              HammerCLIForeman::Sessions.stubs(:storage).returns(dir)
              session_content = {
                :id => nil,
                :user_name => 'admin',
                :auth_type => oauth
              }
              session_path = "#{dir}/https_foreman.example.com"
              File.open(session_path,"w") do |f|
                f.write(session_content.to_json)
              end
              File.chmod(0600, session_path)
              assert_equal subject.authenticator.auth_type, oauth
            end
          end
        end
      end
    end
  end
end