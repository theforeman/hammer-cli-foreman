require File.join(File.dirname(__FILE__), 'test_helper')

describe 'Settings' do
  let(:setting) do
  {
    :name => 'content_action_accept_timeout',
    :full_name => 'Accept action timeout',
    :value => 20,
    :description => 'Time in seconds to wait for a Host to pickup a remote action'
  }
  end

  describe 'list command' do
    before do
      @cmd = %w(settings list)
    end

    it 'lists all settings' do
      api_expects(:settings, :index, 'List').with_params(
        'page' => 1, 'per_page' => 1000
    ).returns(index_response([setting]))


      output = IndexMatcher.new([
        ['NAME', 'FULL NAME', 'VALUE', 'DESCRIPTION'],
        ['content_action_accept_timeout', 'Accept action timeout', '20', 'Time in seconds to wait for a Host to pickup a remote action']
      ])
      expected_result = success_result(output)

      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

  end

  describe 'info' do
    before do
      @cmd = ['setting', 'info']
      @setting = {
        description: 'Fix DB cache on next Foreman restart',
        category: 'Setting::General',
        settings_type: 'boolean',
        default: false,
        created_at: "2020-05-24 09:02:11 UTC",
        updated_at: "2020-07-01 07:42:14 UTC",
        id: 1,
        name: "fix_db_cache",
        full_name: "Fix DB cache",
        value: false,
        category_name: "General"
      }
    end

    it 'should return a setting' do
      params = ['--id=1']
      api_expects(:settings, :show, 'Show a setting').returns(@setting)

      output = OutputMatcher.new([
                                   'Id:            1',
                                   'Name:          fix_db_cache',
                                   'Description:   Fix DB cache on next Foreman restart',
                                   'Category:      General',
                                   'Settings type: boolean',
                                   'Value:         false'
                                 ])

      expected_result = success_result(output)

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'update' do
    before do
      @cmd = ['setting', 'set']
    end

    it 'should update a setting' do
      params = ['--id=1', '--value=true']

      api_expects(:settings, :update, 'Update a setting') do |params|
        (params['setting']['id'] == '1')
        (params['setting']['value'] == 'true')
      end

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Setting [%{name}] updated to [%{value}].\n"), result)
    end
  end

end

