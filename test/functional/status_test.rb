require File.join(File.dirname(__FILE__), 'test_helper')

BASIC_STATUS = {
  'database' => { 'active' => true, 'duration_ms' => 0 },
  'version' => '1.24.0-develop',
  'api' => { 'version' => 'v2' },
  'plugins' => [],
  'smart_proxies' => [],
  'compute_resources' => []
}

STRING_STATUS = Marshal.load(Marshal.dump(BASIC_STATUS)).merge({
  'plugins' => [
    'Foreman plugin: foreman_ansible, 6.0.1, Daniel Lobato Garcia, Ansible integration with Foreman'
  ]
})

STRUCTURED_STATUS = Marshal.load(Marshal.dump(BASIC_STATUS)).merge({
  'plugins' => [
    {'name': 'foreman_ansible', 'version': '6.0.1'}
  ]
})

describe 'status' do
  let(:base_cmd) { %w[status] }

  describe 'foreman' do
    let(:cmd) { base_cmd << 'foreman' }
    let(:status_results) { {'results' => {'foreman' => BASIC_STATUS }} }

    it 'checks status of the foreman system' do
      api_expects(:ping, :statuses, 'Status').returns(status_results)

      output = OutputMatcher.new(
        [
          'Version:           1.24.0-develop',
          'API Version:       v2',
          'Database:',
          '    Status:          ok',
          '    Server Response: Duration: 0ms',
          'Plugins:',
          '',
          'Smart Proxies:',
          '',
          'Compute Resources:'
        ]
      )

      expected_result = success_result(output)
      result = run_cmd(cmd)
      assert_cmd(expected_result, result)
    end
  end

  describe 'foreman with string plugins' do
    let(:cmd) { base_cmd << 'foreman' }
    let(:status_results) { {'results' => {'foreman' => STRING_STATUS }} }

    it 'checks status of the foreman system' do
      api_expects(:ping, :statuses, 'Status').returns(status_results)

      output = OutputMatcher.new(
        [
          'Version:           1.24.0-develop',
          'API Version:       v2',
          'Database:',
          '    Status:          ok',
          '    Server Response: Duration: 0ms',
          'Plugins:',
          ' 1) Name:    foreman_ansible',
          '    Version: 6.0.1',
          'Smart Proxies:',
          '',
          'Compute Resources:'
        ]
      )

      expected_result = success_result(output)
      result = run_cmd(cmd)
      assert_cmd(expected_result, result)
    end
  end

  describe 'foreman with structured plugins' do
    let(:cmd) { base_cmd << 'foreman' }
    let(:status_results) { {'results' => {'foreman' => STRUCTURED_STATUS }} }

    it 'checks status of the foreman system' do
      api_expects(:ping, :statuses, 'Status').returns(status_results)

      output = OutputMatcher.new(
        [
          'Version:           1.24.0-develop',
          'API Version:       v2',
          'Database:',
          '    Status:          ok',
          '    Server Response: Duration: 0ms',
          'Plugins:',
          ' 1) Name:    foreman_ansible',
          '    Version: 6.0.1',
          'Smart Proxies:',
          '',
          'Compute Resources:'
        ]
      )

      expected_result = success_result(output)
      result = run_cmd(cmd)
      assert_cmd(expected_result, result)
    end
  end
end
