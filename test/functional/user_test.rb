require File.join(File.dirname(__FILE__), 'test_helper')

describe "user" do
  let(:minimal_params) { ['--login', 'jane', '--mail', 'jane@test.org', '--password', 'secret', '--auth-source-id', '1'] }
  let(:update_params) { ['--login', 'jane'] }
  let(:user) { { 'id' => '32', 'login' => 'jane' } }

  def expect_with_minimal_params(action, message, &block)
    api_expects(:users, action, message).with_params({
      'user' => {'login' => 'jane', 'mail' => 'jane@test.org', 'password' => 'secret', 'auth_source_id' => 1}}, &block)
  end

  def expect_with_update_params(action, message, &block)
    api_expects(:users, action, message).with_params({
      'user' => {'login' => 'jane'}}, &block)
  end

  describe "create" do
    let(:cmd) { ["user", "create"] }

    it 'resolves default organization name to id' do
      params = ['--default-organization', 'Org1']

      api_expects_search(:organizations, { :name => 'Org1' }).returns(index_response([{ 'id' => '3' }]))
      expect_with_minimal_params(:create, 'Create user with default org') do |par|
        par['user']['default_organization_id'] == '3'
      end.returns(user)

      expected_result = success_result("User [jane] created.\n")

      result = run_cmd(cmd + minimal_params + params)
      assert_cmd(expected_result, result)
    end

    it 'resolves default location name to id' do
      params = ['--default-location', 'Loc1']

      api_expects_search(:locations, { :name => 'Loc1' }).returns(index_response([{ 'id' => '4' }]))
      expect_with_minimal_params(:create, 'Create user with default loc') do |par|
        par['user']['default_location_id'] == '4'
      end.returns(user)

      expected_result = success_result("User [jane] created.\n")

      result = run_cmd(cmd + minimal_params + params)
      assert_cmd(expected_result, result)
    end
  end

  describe "update" do
    let(:cmd) { ["user", "update"] }

    it 'resolves default organization name to id' do
      params = ['--default-organization', 'Org1']

      api_expects_search(:users, { :login => 'jane' }).returns(index_response([user]))
      api_expects_search(:organizations, { :name => 'Org1' }).returns(index_response([{ 'id' => '3' }]))
      expect_with_update_params(:update, 'Update user with default org') do |par|
        par['id'] == '32' &&
        par['user']['default_organization_id'] == '3'
      end.returns(user)
      expected_result = success_result("User [jane] updated.\n")

      result = run_cmd(cmd + update_params + params)

      assert_cmd(expected_result, result)
    end

    it 'resolves default location name to id' do
      params = ['--default-location', 'Loc1']

      api_expects_search(:users, { :login => 'jane' }).returns(index_response([user]))
      api_expects_search(:locations, { :name => 'Loc1' }).returns(index_response([{ 'id' => '4' }]))
      expect_with_update_params(:update, 'Update user with default loc') do |par|
        par['id'] == '32' &&
        par['user']['default_location_id'] == '4'
      end.returns(user)

      expected_result = success_result("User [jane] updated.\n")

      result = run_cmd(cmd + update_params + params)
      assert_cmd(expected_result, result)
    end

    describe "update password" do
      def replace_foreman_connection(connection)
        HammerCLI.context[:api_connection].drop('foreman')
        HammerCLI.context[:api_connection].create('foreman') { connection }
      end

      def connection(user, password)
        authenticator = TestAuthenticator.new(user, password)
        api_connection({:authenticator => authenticator}, FOREMAN_VERSION)
      end

      before do
        @original_api_connection = HammerCLI.context[:api_connection].get('foreman')
      end

      after do
        replace_foreman_connection(@original_api_connection)
      end

      it 'asks for missing current user password when updating own password' do
        replace_foreman_connection(connection('jane', nil))

        params = ['--password', 'changeme']

        api_expects_search(:users, { :login => 'jane' }).returns(index_response([user]))
        api_expects(:users, :show, { :id => 'jane' }).returns(user)
        HammerCLIForeman::OptionSources::UserParams.any_instance
          .expects(:ask_password).with(:current).returns('currentpwd')
        expect_with_update_params(:update, 'Update user password') do |par|
          par['id'] == '32' &&
            par['user']['password'] == 'changeme' &&
            par['user']['current_password'] == 'currentpwd'
        end.returns(user)

        expected_result = success_result("User [jane] updated.\n")
        result = run_cmd(cmd + update_params + params)
        assert_cmd(expected_result, result)
      end

      it 'does not ask for missing current password when updating own password and password was already given' do
        replace_foreman_connection(connection('jane', 'currentpwd'))

        params = ['--password', 'changeme']

        api_expects_search(:users, { :login => 'jane' }).returns(index_response([user]))
        api_expects(:users, :show, { :id => 'jane' }).returns(user)
        HammerCLIForeman::OptionSources::UserParams.any_instance
          .expects(:ask_password).with(:current).never
        expect_with_update_params(:update, 'Update user password') do |par|
          par['id'] == '32' &&
            par['user']['password'] == 'changeme' &&
            par['user']['current_password'] == 'currentpwd'
        end.returns(user)

        expected_result = success_result("User [jane] updated.\n")
        result = run_cmd(cmd + update_params + params)
        assert_cmd(expected_result, result)
      end

      it 'does not ask for current user password when updating password of another user' do
        user_john = { 'id' => '1', 'login' => 'john' }
        replace_foreman_connection(connection('john', nil))

        params = ['--password', 'changeme']

        api_expects_search(:users, { :login => 'jane' }).returns(index_response([user]))
        api_expects(:users, :show, { :id => 'john' }).returns(user_john)
        HammerCLIForeman::OptionSources::UserParams.any_instance
          .expects(:ask_password).with(:current).never
        expect_with_update_params(:update, 'Update user password') do |par|
          par['id'] == '32' &&
            par['user']['password'] == 'changeme'
        end.returns(user)

        expected_result = success_result("User [jane] updated.\n")
        result = run_cmd(cmd + update_params + params)
        assert_cmd(expected_result, result)
      end
    end
  end
end
