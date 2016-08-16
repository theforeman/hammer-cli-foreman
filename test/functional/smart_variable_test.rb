require File.join(File.dirname(__FILE__), 'test_helper')

describe 'smart-variable update' do
  let(:cmd) { %w(smart-variable update) }

  it 'allows to save new name' do
    params = ['--id=1', '--new-variable=name2']

    expected_result = success_result("Smart variable [name2] updated\n")

    api_expects(:smart_variables, :update, 'Update the variable') do |par|
      par['smart_variable']['variable'] == 'name2'
    end.returns(
      'description' => '',
      'parameter_type' => 'string',
      'default_value' => '',
      'hidden_value?' => false,
      'hidden_value' => '*****',
      'validator_type' => '',
      'validator_rule' => nil,
      'override_value_order' => 'fqdn\nhostgroup\nos\ndomain',
      'merge_overrides' => false,
      'merge_default' => false,
      'avoid_duplicates' => false,
      'puppetclass_id' => 68,
      'puppetclass_name' => 'apache',
      'created_at' => '2016-08-16 07:48:29 UTC',
      'updated_at' => '2016-08-16 07:54:05 UTC',
      'variable' => 'name2',
      'id' => 1,
      'override_values_count' => 0,
      'override_values' => []
    )

    result = run_cmd(cmd + params)
    assert_cmd(expected_result, result)
  end
end

describe 'smart-variable info' do
  let(:cmd) { %w(smart-variable info) }
  let(:variable) do
    {
      'description' => '',
      'parameter_type' => 'string',
      'default_value' => "1.2.3.4     aa.con\r\n1.2.3.5     bb.com",
      'hidden_value?' => false,
      'hidden_value' => '*****',
      'validator_type' => '',
      'validator_rule' => nil,
      'override_value_order' => "fqdn\nhostgroup\nos\ndomain",
      'merge_overrides' => false,
      'merge_default' => false,
      'avoid_duplicates' => false,
      'puppetclass_id' => 68,
      'puppetclass_name' => 'apache',
      'created_at' => '2016-08-01 13:05:24 UTC',
      'updated_at' => '2016-08-08 12:36:08 UTC',
      'variable' => 'abc',
      'id' => 1,
      'override_values_count' => 0
    }
  end

  it 'searches by --variable parameter' do
    params = ['--variable=abc']

    api_expects(:smart_variables, :index, 'Search for variable') do |par|
      par[:search] == %(key = "#{variable['variable']}")
    end.returns(index_response([variable]))

    api_expects(:smart_variables, :show, 'Variable details') do |par|
      par['id'] == 1
    end.returns(variable)

    result = run_cmd(cmd + params)
    assert_match(/abc/, result.out)
  end

  it 'searches by deprecated --name parameter' do
    params = ['--name=abc']

    api_expects(:smart_variables, :index, 'Search for variable') do |par|
      par[:search] == %(key = "#{variable['variable']}")
    end.returns(index_response([variable]))

    api_expects(:smart_variables, :show, 'Variable details') do |par|
      par['id'] == 1
    end.returns(variable)

    result = run_cmd(cmd + params)
    assert_match(/abc/, result.out)
  end
end

describe 'smart-variable delete' do
  let(:cmd) { %w(smart-variable delete) }
  let(:variable) do
    {
      'description' => '',
      'parameter_type' => 'string',
      'default_value' => "1.2.3.4     aa.con\r\n1.2.3.5     bb.com",
      'hidden_value?' => false,
      'hidden_value' => '*****',
      'validator_type' => '',
      'validator_rule' => nil,
      'override_value_order' => "fqdn\nhostgroup\nos\ndomain",
      'merge_overrides' => false,
      'merge_default' => false,
      'avoid_duplicates' => false,
      'puppetclass_id' => 68,
      'puppetclass_name' => 'apache',
      'created_at' => '2016-08-01 13:05:24 UTC',
      'updated_at' => '2016-08-08 12:36:08 UTC',
      'variable' => 'abc',
      'id' => 1,
      'override_values_count' => 0
    }
  end

  it 'deletes by --variable parameter' do
    params = ['--variable=abc']

    api_expects(:smart_variables, :index, 'Search for variable') do |par|
      par[:search] == %(key = "#{variable['variable']}")
    end.returns(index_response([variable]))

    api_expects(:smart_variables, :destroy, 'Variable details') do |par|
      par['id'] == 1
    end.returns(variable)

    result = run_cmd(cmd + params)
    assert_match(/abc/, result.out)
  end

  it 'deletes by deprecated --name parameter' do
    params = ['--name=abc']

    api_expects(:smart_variables, :index, 'Search for variable') do |par|
      par[:search] == %(key = "#{variable['variable']}")
    end.returns(index_response([variable]))

    api_expects(:smart_variables, :destroy, 'Variable details') do |par|
      par['id'] == 1
    end.returns(variable)

    result = run_cmd(cmd + params)
    assert_match(/abc/, result.out)
  end
end
