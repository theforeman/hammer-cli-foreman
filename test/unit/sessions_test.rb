require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli_foreman/sessions'
require 'tmpdir'
require 'tempfile'
require 'json'

describe HammerCLIForeman do
  describe HammerCLIForeman::Sessions do
    describe "#get" do
      it 'should create session file when it doesn\'t exist' do
        HammerCLI::Settings.expects(:get).with(:foreman, :use_sessions).returns(true)
        Dir.mktmpdir do |dir|
          HammerCLIForeman::Sessions.stubs(:storage).returns(dir)
          session = HammerCLIForeman::Sessions.get('http://example.com')
          session.id.must_be_nil
          session.auth_type.must_be_nil
          session.user_name.must_be_nil
        end
      end

      it 'should load the session file' do
        HammerCLI::Settings.expects(:get).with(:foreman, :use_sessions).returns(true)
        Dir.mktmpdir do |dir|
          HammerCLIForeman::Sessions.stubs(:storage).returns(dir)
          session_content = {
            :id => '3040b0f04c3a35a499e6837278904d48',
            :user_name => 'admin',
            :auth_type => 'basic_auth'
          }
          session_path = "#{dir}/http_example.com"
          File.open(session_path,"w") do |f|
            f.write(session_content.to_json)
          end
          File.chmod(0600, session_path)

          session = HammerCLIForeman::Sessions.get('http://example.com')
          session.id.must_equal '3040b0f04c3a35a499e6837278904d48'
          session.auth_type.must_equal 'basic_auth'
          session.user_name.must_equal 'admin'
        end
      end

      it 'should create the storage dir if it does not exist' do
        HammerCLI::Settings.expects(:get).with(:foreman, :use_sessions).returns(true)
        Dir.mktmpdir do |dir|
          HammerCLIForeman::Sessions.stubs(:storage).returns(dir)
          FileUtils.rm_rf(dir)
          HammerCLIForeman::Sessions.get('http://example.com')
          File.exist?(dir).must_equal true
        end
      end

      it 'should check permissions (700) on the storage' do
        HammerCLI::Settings.expects(:get).with(:foreman, :use_sessions).returns(true)
        Dir.mktmpdir do |dir|
          HammerCLIForeman::Sessions.stubs(:storage).returns(dir)
          FileUtils.chmod(0777, dir)
          _, err = capture_io { HammerCLIForeman::Sessions.get('http://example.com') }
          err.must_equal("Invalid permissions for #{dir}: 40777, expected 40700.\n" \
              "Using session auth with invalid permissions on session files is not recommended.\n")
        end
      end

      it 'should check permissions (600) on the storage file' do
        HammerCLI::Settings.expects(:get).with(:foreman, :use_sessions).returns(true)
        Dir.mktmpdir do |dir|
          HammerCLIForeman::Sessions.stubs(:storage).returns(dir)
          session_content = {
            :id => '3040b0f04c3a35a499e6837278904d48',
            :user_name => 'admin',
            :auth_type => 'basic_auth'
          }
          session_path = "#{dir}/http_example.com"
          File.open(session_path,"w") do |f|
            f.write(session_content.to_json)
          end
          File.chmod(0666, session_path)

          _, err = capture_io { HammerCLIForeman::Sessions.get('http://example.com') }
          err.must_equal("Invalid permissions for #{session_path}: 100666, expected 100600.\n" \
              "Using session auth with invalid permissions on session files is not recommended.\n")
        end
      end

      it 'should fail if sessions are not enabled' do
        HammerCLI::Settings.expects(:get).with(:foreman, :use_sessions).returns(false)
        e = proc { HammerCLIForeman::Sessions.get('http://example.com')}.must_raise RuntimeError
        e.message.must_equal "Sessions are not enabled, please check your Hammer settings."
      end
    end

    describe "#enabled?" do
      it 'tests sessions are enabled' do
        HammerCLI::Settings.expects(:get).with(:foreman, :use_sessions).returns(true)
        HammerCLIForeman::Sessions.enabled?.must_equal true
      end

      it 'tests sessions are disabled' do
        HammerCLI::Settings.expects(:get).with(:foreman, :use_sessions).returns(false)
        HammerCLIForeman::Sessions.enabled?.must_equal false
      end
    end

    describe "#session_file" do
      it 'should return file path for session' do
        file_path = HammerCLIForeman::Sessions.session_file('http://example.com')
        file_path.must_equal(File.join(HammerCLIForeman::Sessions.storage, 'http_example.com'))
      end

      it 'should handle invalid url' do
        e = proc { HammerCLIForeman::Sessions.session_file('/\/')}.must_raise RuntimeError
        e.message.must_equal "The url (/\\/) is not a valid URL. Session can not be created."
      end

      it 'should handle empty url' do
        e = proc { HammerCLIForeman::Sessions.session_file('')}.must_raise RuntimeError
        e.message.must_equal "The url is empty. Session can not be created."
      end
    end
  end

  describe HammerCLIForeman::Session do
    it 'should be able to store its data' do
      Tempfile.create('session') do |f|
        session = HammerCLIForeman::Session.new(f.path)
        session.id = '3040b0f04c3a35a499e6837278904d48'
        session.auth_type = 'basic_auth'
        session.user_name = 'admin'
        session.store

        session = HammerCLIForeman::Session.new(f.path)
        session.id.must_equal '3040b0f04c3a35a499e6837278904d48'
        session.auth_type.must_equal 'basic_auth'
        session.user_name.must_equal 'admin'
      end
    end

    it 'should store session file with 600 perm' do
      Tempfile.create('session') do |f|
        session = HammerCLIForeman::Session.new(f.path)
        session.store
        File.stat(f.path).mode.to_s(8).must_equal '100600'
      end
    end

    it 'should reset invalid session file' do
      Tempfile.create('session') do |f|
        f << '{[Invalid'
        f.rewind
        _, err = capture_io do
          session = HammerCLIForeman::Session.new(f.path)
          session.id = nil
          session.auth_type = nil
          session.user_name = nil
        end
        err.must_equal("Invalid session data. Resetting the session.\n")
      end
    end

    describe ".destroy" do
      it 'should be able to destroy session' do
        Tempfile.create('session') do |f|
          session = HammerCLIForeman::Session.new(f.path)
          session.id = '3040b0f04c3a35a499e6837278904d48'
          session.auth_type = 'basic_auth'
          session.user_name = 'admin'
          session.destroy

          session = HammerCLIForeman::Session.new(f.path)
          session.id.must_be_nil
          session.auth_type.must_equal 'basic_auth'
          session.user_name.must_equal 'admin'
        end
      end
    end

    describe ".valid?" do
      it "tests if session is invalid" do
        Tempfile.create('session') do |f|
          session = HammerCLIForeman::Session.new(f.path)
          session.id = nil
          session.auth_type = 'basic_auth'
          session.user_name = 'admin'
          session.valid?.must_equal false
        end
      end

      it "tests if session is valid" do
        Tempfile.create('session') do |f|
          session = HammerCLIForeman::Session.new(f.path)
          session.id = '34252624635723572357234'
          session.auth_type = 'basic_auth'
          session.user_name = 'admin'
          session.valid?.must_equal true
        end
      end
    end
  end
end
