require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLIForeman::Api::SessionAuthenticatorWrapper do

  let(:wrapped_auth) { mock() }
  let(:url) { 'http://foreman.example.com' }
  let(:args) { {} }
  let(:request) { Net::HTTP::Get.new(URI(url), {}) }

  def session_file(dir)
    "#{dir}/http_foreman.example.com"
  end

  def prepare_session_storage(options = {}, &block)
    options[:dir_permissions] ||= 0700
    options[:file_permissions] ||= 0600

    out = err = ""

    dir = Dir.mktmpdir
    begin
      FileUtils.chmod(options[:dir_permissions], dir)

      if options[:session_id]
        File.open(session_file(dir), 'w', options[:file_permissions]) do |f|
          f.write(options[:session_id])
        end
      end

      out, err = capture_io do
        auth = HammerCLIForeman::Api::SessionAuthenticatorWrapper.new(wrapped_auth, url, dir)
        yield(auth, dir) if block_given?
      end
    ensure
      FileUtils.remove_entry(dir)
    end

    return dir, out, err
  end

  describe '#initialize' do
    context "when there's saved session" do
      it 'warns when session directory has wrong permissions' do
        dir, out, err = prepare_session_storage :dir_permissions => 0744

        assert_match /Invalid permissions for #{dir}: 40744, expected 40700/, err
        assert_match /Can't use session auth due to invalid permissions on session files/, err
      end

      it 'warns when session file has wrong permissions' do
        dir, out, err = prepare_session_storage :session_id => 'SOME_SESSION_ID', :file_permissions => 0644

        assert_match /Invalid permissions for #{session_file(dir)}: 100644, expected 100600/, err
        assert_match /Can't use session auth due to invalid permissions on session files/, err
      end
    end
  end

  describe '#authenticate' do
    context "when there's saved session" do
      it 'sets session id in cookies' do
        prepare_session_storage :session_id => 'SOME_SESSION_ID' do |auth, dir|
          auth.authenticate(request, args)

          assert_equal "_session_id=SOME_SESSION_ID", request['Cookie']
        end
      end

      it 'ignores session when the session file has wrong permissions' do
        prepare_session_storage :session_id => 'SOME_SESSION_ID', :file_permissions => 0644 do |auth, dir|
          wrapped_auth.expects(:authenticate).with(request, args)
          auth.authenticate(request, args)

          assert_nil request['Cookie']
        end
      end

      it 'ignores session when the directory has wrong permissions' do
        prepare_session_storage :session_id => 'SOME_SESSION_ID', :dir_permissions => 0744 do |auth, dir|
          wrapped_auth.expects(:authenticate).with(request, args)
          auth.authenticate(request, args)

          assert_nil request['Cookie']
        end
      end
    end

    context "when no session is saved" do
      it 'passes to wrapped authenticator' do
        prepare_session_storage do |auth, dir|
          wrapped_auth.expects(:authenticate).with(request, args)
          auth.authenticate(request, args)
        end
      end
    end
  end

  describe '#error' do
    it 'deletes saved session on unauthorized exception when there is existing session' do
      prepare_session_storage :session_id => 'SOME_SESSION_ID' do |auth, dir|
        ex = RestClient::Unauthorized.new

        auth.error(ex)

        refute File.exist?(session_file(dir))
      end
    end

    it 'passes exception to wrapped authenticator on unauthorized exception when there is no existing session' do
      prepare_session_storage do |auth, dir|
        ex = RestClient::Unauthorized.new

        wrapped_auth.expects(:error).with(ex)
        auth.error(ex)
      end
    end
  end

  describe '#response' do
    it "saves session id if it's in response cookies" do
      prepare_session_storage :session_id => 'SOME_SESSION_ID' do |auth, dir|
        resp = stub(:cookies => {'_session_id' => 'NEW_SESSION_ID'}, :code => 200)

        wrapped_auth.expects(:response).with(resp)
        auth.response(resp)

        assert_equal 'NEW_SESSION_ID', File.read(session_file(dir))
      end
    end

    it "ignores requests without session cookie" do
      prepare_session_storage do |auth, dir|
        resp = stub(:cookies => {}, :code => 200)

        wrapped_auth.expects(:response).with(resp)
        auth.response(resp)

        refute File.exist?(session_file(dir))
      end
    end

    it "ignores unauthorized requests" do
      prepare_session_storage do |auth, dir|
        resp = stub(:cookies => {}, :code => 401)

        wrapped_auth.expects(:response).with(resp)
        auth.response(resp)

        refute File.exist?(session_file(dir))
      end
    end
  end

end
