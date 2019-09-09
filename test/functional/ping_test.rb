require File.join(File.dirname(__FILE__), 'test_helper')

describe 'ping' do
  let(:base_cmd) { %w[ping] }

  describe 'foreman' do
    let(:cmd) { base_cmd << 'foreman' }
    let(:ping_results) do
      {
        'results' => {
          'foreman' => {
            'database' => { 'active' => true, 'duration_ms' => 0 }
          }
        }
      }
    end

    it 'pings foreman system' do
      api_expects(:ping, :ping, 'Ping').returns(ping_results)

      output = OutputMatcher.new(
        [
          'database:',
          '    Status:          ok',
          '    Server Response: Duration: 0ms'
        ]
      )

      expected_result = success_result(output)
      result = run_cmd(cmd)
      assert_cmd(expected_result, result)
    end
  end
end
