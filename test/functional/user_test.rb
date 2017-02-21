require File.join(File.dirname(__FILE__), 'test_helper')

describe "user" do
  let(:minimal_params) { ['--login', 'jane', '--mail', 'jane@test.org', '--password', 'secret', '--auth-source-id', '1'] }
  let(:user) { { 'id' => '32', 'login' => 'jane' } }

  def expect_with_minimal_params(action, message, &block)
    api_expects(:users, action, message) do |par|
      user = par['user']
      user['login'] == 'jane' &&
      user['mail'] == 'jane@test.org' &&
      user['password'] == 'secret' &&
      user['auth_source_id'] == '1' &&
      yield(par)
    end
  end

  describe "create" do
    let(:cmd) { ["user", "create"] }

    it 'resolves default organization name to id' do
      params = ['--default-organization', 'Org1']

      api_expects_search(:organizations, { :name => 'Org1' }).returns(index_response([{ 'id' => '3' }]))
      expect_with_minimal_params(:create, 'Create user with default org') do |par|
        par['user']['default_organization_id'] == '3'
      end.returns(user)

      expected_result = success_result("User [jane] created\n")

      result = run_cmd(cmd + minimal_params + params)
      assert_cmd(expected_result, result)
    end

    it 'resolves default location name to id' do
      params = ['--default-location', 'Loc1']

      api_expects_search(:locations, { :name => 'Loc1' }).returns(index_response([{ 'id' => '4' }]))
      expect_with_minimal_params(:create, 'Create user with default loc') do |par|
        par['user']['default_location_id'] == '4'
      end.returns(user)

      expected_result = success_result("User [jane] created\n")

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
      expect_with_minimal_params(:update, 'Update user with default org') do |par|
        par['id'] == '32' &&
        par['user']['default_organization_id'] == '3'
      end.returns(user)

      expected_result = success_result("User [jane] updated\n")

      result = run_cmd(cmd + minimal_params + params)
      assert_cmd(expected_result, result)
    end

    it 'resolves default location name to id' do
      params = ['--default-location', 'Loc1']

      api_expects_search(:users, { :login => 'jane' }).returns(index_response([user]))
      api_expects_search(:locations, { :name => 'Loc1' }).returns(index_response([{ 'id' => '4' }]))
      expect_with_minimal_params(:update, 'Update user with default loc') do |par|
        par['id'] == '32' &&
        par['user']['default_location_id'] == '4'
      end.returns(user)

      expected_result = success_result("User [jane] updated\n")

      result = run_cmd(cmd + minimal_params + params)
      assert_cmd(expected_result, result)
    end
  end
end
