require File.join(File.dirname(__FILE__), 'test_helper')

describe 'status' do
  let(:base_cmd) { %w[status] }

  describe 'foreman' do
    let(:cmd) { base_cmd << 'foreman' }
    let(:status_results) do
      {
        'results' => {
          'foreman' => {
            'database' => { 'active' => true, 'duration_ms' => 0 },
            'version' => '1.24.0-develop',
            'api' => { 'version' => 'v2' },
            'plugins' => [],
            'smart_proxies' => [],
            'compute_resources' => []
          }
        }
      }
    end

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
end
