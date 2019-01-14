require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLIForeman::Api::Oauth::PasswordGrant do
  let(:request) { mock().stubs({}) }
  let(:args) { {} }
  let(:params) {{
    username: 'user1',
    password: 'password',
    oidc_token_endpoint: 'https://keycloak-server-url.example.com/token',
    oidc_client_id: 'hammer-cli-foreman'
  }}

  describe '#set_token' do
    let(:auth) { HammerCLIForeman::Api::Oauth::PasswordGrant.new(nil, nil, nil, nil) }

    it 'sets token' do
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token)
        .with(params[:username], params[:password]).returns('token')
      auth.set_token(params[:oidc_token_endpoint], params[:oidc_client_id], params[:username], params[:password])
      assert_equal 'token', auth.token
    end

    it 'sets token as nil when all input parameter are missing' do
      auth.set_token(nil, nil, nil, nil)
      assert_equal nil, auth.token
    end

    it 'sets token as nil when any input parameter is missing' do
      auth.set_token(nil, params[:oidc_client_id], params[:username], params[:password])
      assert_equal nil, auth.token
    end
  end

  context "interactive mode" do
    before :each do
      HammerCLI.stubs(:interactive?).returns true
    end

    it "asks for username, password, url, realm and oidc_client_id when nothing was provided" do
      auth = HammerCLIForeman::Api::Oauth::PasswordGrant.new(nil, nil, nil, nil)
      auth.stubs(:ask_user).with('Username: ').returns(params[:username])
      auth.stubs(:ask_user).with('Password: ', true).returns(params[:password])
      auth.stubs(:ask_user).with('Openidc Provider Token Endpoint: ').returns(params[:oidc_token_endpoint])
      auth.stubs(:ask_user).with('Client ID: ').returns(params[:oidc_client_id])
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token).with(params[:username], params[:password]).returns('token')
      auth.authenticate(request, args)

      assert_equal request.keys, ['Authorization']
      assert_equal request.values, ['Bearer token']
    end

    it "asks for the url when url wasn't provided" do
      auth = HammerCLIForeman::Api::Oauth::PasswordGrant.new(nil, params[:oidc_client_id], params[:username], params[:password])
      auth.stubs(:ask_user).with('Openidc Provider Token Endpoint: ').returns(params[:oidc_token_endpoint])
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token).with(params[:username], params[:password]).returns('token')
      auth.authenticate(request, args)

      assert_equal request.keys, ['Authorization']
      assert_equal request.values, ['Bearer token']
    end

    it "asks for the oidc_client_id when oidc_client_id wasn't provided" do
      auth = HammerCLIForeman::Api::Oauth::PasswordGrant.new(params[:oidc_token_endpoint], nil, params[:username], params[:password])
      auth.stubs(:ask_user).with('Client ID: ').returns(params[:oidc_client_id])
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token).with(params[:username], params[:password]).returns('token')
      auth.authenticate(request, args)

      assert_equal request.keys, ['Authorization']
      assert_equal request.values, ['Bearer token']
    end

    it "asks for the username when username wasn't provided" do
      auth = HammerCLIForeman::Api::Oauth::PasswordGrant.new(params[:oidc_token_endpoint], params[:oidc_client_id], nil, params[:password])
      auth.stubs(:ask_user).with('Username: ').returns(params[:username])
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token).with(params[:username], params[:password]).returns('token')
      auth.authenticate(request, args)

      assert_equal request.keys, ['Authorization']
      assert_equal request.values, ['Bearer token']
    end

    it "asks for the password when password wasn't provided" do
      auth = HammerCLIForeman::Api::Oauth::PasswordGrant.new(params[:oidc_token_endpoint], params[:oidc_client_id], params[:username], nil)
      auth.stubs(:ask_user).with('Password: ', true).returns(params[:password])
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token).with(params[:username], params[:password]).returns('token')
      auth.authenticate(request, args)

      assert_equal request.keys, ['Authorization']
      assert_equal request.values, ['Bearer token']
    end
  end
end
