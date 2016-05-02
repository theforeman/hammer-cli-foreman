require File.join(File.dirname(__FILE__), 'test_helper')


describe 'sc-params update' do
  let(:cmd) { %w(sc-param update) }

  it 'does not allow to update parameter name' do
    params = ['--id=1', '--new-name=name2']

    expected_result = usage_error_result(
      cmd,
      "Unrecognised option '--new-name'",
      "Could not update the parameter"
    )

    api_expects_no_call
    result = run_cmd(cmd + params)
    assert_cmd(expected_result, result)
  end

end
