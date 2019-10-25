require File.join(File.dirname(__FILE__), '../../test_helper')

describe HammerCLIForeman::Api::Oauth::AuthenticationCodeGrant do
  let(:request) { mock().stubs({}) }
  let(:args) { {} }
  let(:params) {{
    oidc_redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
    oidc_token_endpoint: 'https://keycloak-server-url.example.com/token',
    oidc_authorization_endpoint: 'https://keycloak-server-url.example.com/auth/',
    oidc_client_id: 'hammer-cli-foreman'
  }}

  describe '#set_token' do
    let(:auth) { HammerCLIForeman::Api::Oauth::AuthenticationCodeGrant.new(nil, nil, nil, nil) }

    it 'sets token' do
      auth.stubs(:get_code).returns('code')
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token_via_2fa).returns('token')
      auth.set_token(params[:oidc_token_endpoint], params[:oidc_authorization_endpoint], params[:oidc_client_id], params[:oidc_redirect_uri])
      assert_equal 'token', auth.token
    end

    it 'sets token as nil when all input parameter are missing' do
      auth.stubs(:get_code).returns('code')
      auth.set_token(nil, nil, nil, nil)
      assert_equal nil, auth.token
    end

    it 'sets token as nil when any input parameter is missing' do
      auth.stubs(:get_code).returns('code')
      auth.set_token(nil, params[:oidc_authorization_endpoint], params[:oidc_client_id], params[:oidc_redirect_uri])
      assert_equal nil, auth.token
    end
  end

  context "interactive mode" do
    before :each do
      HammerCLI.stubs(:interactive?).returns true
    end

    it "asks for url, realm and oidc_client_id when nothing was provided" do
      auth = HammerCLIForeman::Api::Oauth::AuthenticationCodeGrant.new(nil, nil, nil, nil)
      auth.stubs(:ask_user).with('Openidc Provider Authorization Endpoint: ').returns(params[:oidc_authorization_endpoint])
      auth.stubs(:ask_user).with('Openidc Provider Token Endpoint: ').returns(params[:oidc_token_endpoint])
      auth.stubs(:ask_user).with('Client ID: ').returns(params[:oidc_client_id])
      auth.stubs(:ask_user).with('Redirect URI: ').returns(params[:oidc_redirect_uri])
      auth.stubs(:get_code).returns('code')
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token_via_2fa).returns('token')
      auth.authenticate(request, args)

      assert_equal request.keys, ['Authorization']
      assert_equal request.values, ['Bearer token']
    end

    it "asks for the token endpoint when it wasn't provided" do
      auth = HammerCLIForeman::Api::Oauth::AuthenticationCodeGrant.new(nil, params[:oidc_authorization_endpoint], params[:oidc_client_id], params[:oidc_redirect_uri])
      auth.stubs(:ask_user).with('Openidc Provider Token Endpoint: ').returns(params[:oidc_token_endpoint])
      auth.stubs(:get_code).returns('code')
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token_via_2fa).returns('token')
      auth.authenticate(request, args)

      assert_equal request.keys, ['Authorization']
      assert_equal request.values, ['Bearer token']
    end

    it "asks for the authorization code endpoint when it wasn't provided" do
      auth = HammerCLIForeman::Api::Oauth::AuthenticationCodeGrant.new(params[:oidc_token_endpoint], nil, params[:oidc_client_id], params[:oidc_redirect_uri])
      auth.stubs(:ask_user).with('Openidc Provider Authorization Endpoint: ').returns(params[:oidc_authorization_endpoint])
      auth.stubs(:get_code).returns('code')
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token_via_2fa).returns('token')
      auth.authenticate(request, args)

      assert_equal request.keys, ['Authorization']
      assert_equal request.values, ['Bearer token']
    end

    it "asks for the url when url wasn't provided" do
      auth = HammerCLIForeman::Api::Oauth::AuthenticationCodeGrant.new(params[:oidc_token_endpoint], params[:oidc_authorization_endpoint], nil, params[:oidc_redirect_uri])
      auth.stubs(:ask_user).with('Client ID: ').returns(params[:oidc_client_id])
      auth.stubs(:get_code).returns('code')
      HammerCLIForeman::OpenidConnect.any_instance.stubs(:get_token_via_2fa).returns('token')
      auth.authenticate(request, args)

      assert_equal request.keys, ['Authorization']
      assert_equal request.values, ['Bearer token']
    end
  end
end
