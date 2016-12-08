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
    it "desn't ask for credentials when tye're not provided" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, nil)
      auth.expects(:ask_user).never

      request.expects(:basic_auth).with(nil, nil)
      auth.authenticate(request, args)
    end
  end

  describe '#user' do
    it "asks for username whe it wasn't provided" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new(nil, nil)
      auth.expects(:ask_user).with("[Foreman] Username: ").returns('user1')

      assert_equal 'user1', auth.user
    end

    it "returns the username" do
      auth = HammerCLIForeman::Api::InteractiveBasicAuth.new('user1', nil)

      assert_equal 'user1', auth.user
    end
  end
end
