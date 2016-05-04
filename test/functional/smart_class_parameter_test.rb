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

describe 'sc-params add-override-value' do
  let(:cmd) { %w(sc-param add-override-value) }
  let(:override_value) { 'something' }
  let(:match) { 'domain = example.com' }
  let(:puppet_class) { { 'name' => 'motd', 'id' => '1' } }
  let(:parameter) { { 'name' => 'content', 'id' => '2' } }
  let(:base) { [
    '--puppet-class', puppet_class['name'],
    '--smart-class-parameter', parameter['name'],
    '--match', match
  ] }

  it 'allows to set value' do
    params = ['--value', override_value]

    expected_result = success_result("Override value created\n")

    api_expects(:puppetclasses, :index, 'Find puppet class') do |par|
      par[:search] == %Q(name = "#{puppet_class['name']}")
    end.returns(index_response('motd' => [puppet_class]))

    api_expects(:smart_class_parameters, :index, 'Find smart parameter') do |par|
      par[:search] == %Q(key = "#{parameter['name']}") &&
        par[:puppetclass_id] == puppet_class['id']
    end.returns(index_response([parameter]))

    api_expects(:override_values, :create, 'Create override value') do |par|
      val = par['override_value']
      par['smart_class_parameter_id'] == parameter['id'] &&
        val['match'] == match &&
        val['value'] == override_value
    end

    result = run_cmd(cmd + base + params)
    assert_cmd(expected_result, result)
  end

  it 'does not allow to use puppet default and value at the same time' do
    params = %w(--value something --use-puppet-default 1)

    expected_result = usage_error_result(
      cmd,
      "You can't set all options --value, --use-puppet-default at one time",
      'Could not create the override_value'
    )

    api_expects_no_call
    result = run_cmd(cmd + base + params)
    assert_cmd(expected_result, result)
  end
end
