require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLIForeman::Api::InteractiveBasicAuth do
  let(:request) { mock() }
  let(:args) { {} }

  context "interactive mode" do
    before :each do
      HammerCLI.stubs(:interactive?).returns true
    end

    it "asks for username and password when nothing was provided" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, nil)
      auth.stubs(:ask_user).with("[Foreman] Username: ").returns('user1')
      auth.stubs(:ask_user).with("[Foreman] Password for user1: ", true).returns('pass')

      request.expects(:basic_auth).with('user1', 'pass')
      auth.authenticate(request, args)
    end

    it "asks for the password when username wasn't provided" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new('user1', nil)
      auth.stubs(:ask_user).with("[Foreman] Password for user1: ", true).returns('pass')

      request.expects(:basic_auth).with('user1', 'pass')
      auth.authenticate(request, args)
    end

    it "asks for the username when password wasn't provided" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, 'pass')
      auth.stubs(:ask_user).with("[Foreman] Username: ").returns('user1')

      request.expects(:basic_auth).with('user1', 'pass')
      auth.authenticate(request, args)
    end

    it "sets provided credentials" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new('user1', 'pass')

      request.expects(:basic_auth).with('user1', 'pass')
      auth.authenticate(request, args)
    end
  end

  context "non-interactive mode" do
    it "doesn't ask for credentials when they're not provided" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, nil)
      auth.expects(:ask_user).never

      request.expects(:basic_auth).with(nil, nil)
      auth.authenticate(request, args)
    end
  end

  describe '#user' do
    it "returns nil when username wasn't provided" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, nil)

      assert_nil auth.user
    end

    it "returns the username" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new('user1', nil)

      assert_equal 'user1', auth.user
    end
  end

  describe '#password' do
    it "returns nil when password wasn't provided" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, nil)

      assert_nil auth.password
    end

    it "returns the password" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, 'testpswd')

      assert_equal 'testpswd', auth.password
    end
  end

  describe '#error' do
    let(:auth) { HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, nil) }

    it 'overrides unauthorized exception' do
      ex = RestClient::Unauthorized.new
      new_ex = auth.error(ex)

      assert_equal 'Invalid username or password.', new_ex.message
    end

    it 'does not override other exceptions' do
      ex = RuntimeError.new('Some error')
      new_ex = auth.error(ex)

      assert_nil new_ex
    end

    it 'respect server error' do
      ex = RestClient::Unauthorized.new
      response = mock()
      response.stubs(:body).returns('{"error": {"message": "Unable to authenticate user admin"}}')
      ex.response = response
      new_ex = auth.error(ex)

      assert_equal 'Unable to authenticate user admin', new_ex.message
    end
  end

  describe '#set_credentials' do
    let(:auth) { HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, nil) }

    it 'sets username and password' do
      auth.set_credentials('admin', 'password')
      assert_equal 'admin', auth.user
    end
  end

  describe '#clear' do
    let(:auth) { HammerCLIForeman::Api::InteractiveBasicAuth.new('user', 'password') }

    it 'clears username and password' do
      auth.clear
      assert_nil auth.user
    end
  end

  describe '#status' do
    let(:auth) { HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, nil) }

    it 'says user is logged only when both username and password are present' do
      auth.set_credentials('admin', 'password')
      assert_equal "Using configured credentials for user 'admin'.", auth.status
    end

    it 'says user is not logged when only username is present' do
      auth.set_credentials('admin', nil)
      assert_equal "Credentials are not configured.", auth.status
    end

    it 'says user is not logged when only password is present' do
      auth.set_credentials(nil, 'password')
      assert_equal "Credentials are not configured.", auth.status
    end
  end
end
