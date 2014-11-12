require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLIForeman::BasicCredentials do

  context "interactive mode" do

    before :each do
      HammerCLI.stubs(:interactive?).returns true
    end

    after :each do
      HammerCLI.stubs(:interactive?).returns false
    end

    it "should ask for username when not provided" do
      creds = HammerCLIForeman::BasicCredentials.new()
      creds.stubs(:ask_user).returns('user')
      creds.username.must_equal 'user'
    end

    it "should not ask the username when provided" do
      creds = HammerCLIForeman::BasicCredentials.new({ :username => 'user'})
      creds.stubs(:ask_user).returns('other_user')
      creds.username.must_equal 'user'
    end

    it "should ask for password when not provided" do
      creds = HammerCLIForeman::BasicCredentials.new()
      creds.stubs(:ask_user).returns('pass')
      creds.password.must_equal 'pass'
    end

    it "should not ask the password when provided" do
      creds = HammerCLIForeman::BasicCredentials.new({ :password => 'pass'})
      creds.stubs(:ask_user).returns('other_pass')
      creds.password.must_equal 'pass'
    end

    it "should export the credentials" do
      creds = HammerCLIForeman::BasicCredentials.new()
      creds.stubs(:ask_user).returns('user','pass')
      creds.to_params.must_equal({ :user => 'user', :password => 'pass' })
    end
  end

  context "non-interactive mode" do

    it "should not ask for username when not provided" do
      creds = HammerCLIForeman::BasicCredentials.new()
      creds.username.must_be_nil
    end

    it "should not ask for password when not provided" do
      creds = HammerCLIForeman::BasicCredentials.new()
      creds.password.must_be_nil
    end
  end

end
