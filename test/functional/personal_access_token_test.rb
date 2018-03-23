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
      :created_at => '01/10/2016',
      :expires_at => '01/02/2017',
      :last_used_at => '24/12/2016',
      :active? => false
    }
  end
  let(:active_access_token) do
    {
      :id => 2,
      :user_id => user[:id],
      :name => 'test2',
      :created_at => '01/10/2016',
      :expires_at => '01/02/2048',
      :last_used_at => '01/02/2018',
      :active? => true
    }
  end

  describe 'list' do
    let(:cmd) { base_cmd << 'list' }
    let(:params) { ['--user-id=1'] }

    it 'lists all access tokens for a given user' do
      api_expects(:personal_access_tokens, :index, 'List').with_params(
        'user_id' => 1, 'page' => 1, 'per_page' => 1000
      ).returns(index_response([access_token, active_access_token]))

      output = IndexMatcher.new([
        ['ID', 'NAME',  'ACTIVE', 'EXPIRES AT'],
        ['1',  'test',  'no',     '2017/02/01 00:00:00' ],
        ['2',  'test2', 'yes',    '2048/02/01 00:00:00' ]
      ])
      expected_result = success_result(output)

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

      output = OutputMatcher.new([
        "Id:           1",
        "Name:         test",
        "Active:       no",
        "Expires at:   2017/02/01 00:00:00",
        "Created at:   2016/10/01 00:00:00",
        "Last used at: 2016/12/24 00:00:00",
      ])

      expected_result = success_result(output)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'revoke' do
    let(:cmd) { base_cmd << 'revoke' }
    let(:params) { ['--id=1', '--user-id=1'] }
    it 'deletes an access token to a given user' do
      api_expects(:personal_access_tokens, :destroy, 'Revoke PAT').with_params(
        'id' => '1', 'user_id' => 1
      ).returns(access_token)

      expected_result = success_result(
        "Personal access token [#{access_token[:name]}] revoked.\n"
      )

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end
end
