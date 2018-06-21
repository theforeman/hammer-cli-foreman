require File.join(File.dirname(__FILE__), '..', 'test_helper')

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

end

