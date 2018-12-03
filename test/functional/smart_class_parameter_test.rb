require File.join(File.dirname(__FILE__), 'test_helper')


describe 'sc-params update' do
  let(:cmd) { %w(sc-param update) }

  it 'does not allow to update parameter name' do
    params = ['--id=1', '--new-name=name2']

    expected_result = usage_error_result(
      cmd,
      "Unrecognised option '--new-name'.",
      "Could not update the parameter"
    )

    api_expects_no_call
    result = run_cmd(cmd + params)
    assert_cmd(expected_result, result)
  end

end

describe 'sc-params add-matcher' do
  let(:cmd) { %w(sc-param add-matcher) }
  let(:override_value) { 'something' }
  let(:match) { 'domain = example.com' }
  let(:puppet_class) { { 'name' => 'motd', 'id' => '1' } }
  let(:parameter) { { 'name' => 'content', 'id' => '2' } }
  let(:base) { [
    '--puppet-class', puppet_class['name'],
    '--smart-class-parameter', parameter['name'],
    '--match', match
  ] }

  def api_expects_parameter_search(puppet_class, parameter)
    api_expects(:puppetclasses, :index, 'Find puppet class') do |par|
      par[:search] == %Q(name = "#{puppet_class['name']}")
    end.returns(index_response('motd' => [puppet_class]))

    api_expects(:smart_class_parameters, :index, 'Find smart parameter') do |par|
      par[:search] == %Q(key = "#{parameter['name']}") &&
        par[:puppetclass_id] == puppet_class['id']
    end.returns(index_response([parameter]))
  end

  it 'allows to set value' do
    params = ['--value', override_value]
    expected_result = success_result("Override value created.\n")

    api_expects_parameter_search(puppet_class, parameter)

    api_expects(:override_values, :create, 'Create override value').with_params(
      :smart_class_parameter_id => parameter['id'],
      :override_value => {
        :match => match,
        :value => override_value
      }
    )

    result = run_cmd(cmd + base + params)
    assert_cmd(expected_result, result)
  end

  it 'allows to set value with disabled puppet default' do
    params = ['--value', override_value, '--use-puppet-default', false]
    expected_result = success_result("Override value created.\n")

    api_expects_parameter_search(puppet_class, parameter)

    api_expects(:override_values, :create, 'Create override value').with_params(
      :smart_class_parameter_id => parameter['id'],
      :override_value => {
        :match => match,
        :value => override_value,
        :use_puppet_default => false
      }
    )

    result = run_cmd(cmd + base + params)
    assert_cmd(expected_result, result)
  end

  it 'does not allow to use puppet default and value at the same time' do
    params = ['--value', 'something', '--use-puppet-default', true]

    expected_result = usage_error_result(
      cmd,
      "Cannot use --value when --use-puppet-default is true.",
      'Could not create the override value'
    )

    api_expects_parameter_search(puppet_class, parameter)

    result = run_cmd(cmd + base + params)
    assert_cmd(expected_result, result)
  end
end
