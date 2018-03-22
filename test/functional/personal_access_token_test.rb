require File.join(File.dirname(__FILE__), 'test_helper')

describe 'personal_access_token' do
  let(:base_cmd) { ['user', 'access-token'] }
  let(:user) do
    {
     :id => 1,
     :name => 'admin'
    }
  end
  let(:access_token) do
    {
      :id => 1,
      :user_id => user[:id],
      :name => 'test',
      :expires_at => '01/01/2048'
    }
  end

  describe 'list' do
    let(:cmd) { base_cmd << 'list' }
    let(:params) { ['--user-id=1'] }

    it 'lists all access tokens for a given user' do
      api_expects(:personal_access_tokens, :index, 'List').with_params(
        'user_id' => 1, 'page' => 1, 'per_page' => 1000
      ).returns(index_response([access_token]))

      expected_result = success_result(/#{access_token[:name]}/)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'create' do
    let(:cmd) { base_cmd << 'create' }
    let(:params) { ['--user-id=1', '--expires-at=01/01/2048', '--name=test'] }
    let(:access_token) do
      {
        :id => 1,
        :user_id => user[:id],
        :name => 'test',
        :expires_at => '01/01/2048',
        :token_value => 'value'
      }
    end

    it 'creates an access token to a given user' do
      api_expects(:personal_access_tokens, :create).with_params(
        'user_id' => 1, 'personal_access_token' => {
          'expires_at' => '01/01/2048', 'name' => 'test'
        }
      ).returns(access_token)

      expected_result = success_result(/#{access_token[:value]}/)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'info' do
    let(:cmd) { base_cmd << 'info' }
    let(:params) { ['--id=1', '--user-id=1'] }

    it 'shows the personal access token' do
      api_expects(:personal_access_tokens, :show, 'Show PAT').with_params(
        'id' => '1', 'user_id' => 1
      ).returns(access_token)

      expected_result = success_result(/#{access_token[:name]}/)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'delete' do
    let(:cmd) { base_cmd << 'delete' }
    let(:params) { ['--id=1', '--user-id=1'] }
    it 'deletes an access token to a given user' do
      api_expects(:personal_access_tokens, :destroy, 'Delete PAT').with_params(
        'id' => '1', 'user_id' => 1
      ).returns(access_token)

      expected_result = success_result(
        "Personal access token [#{access_token[:name]}] deleted.\n"
      )

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end
end
