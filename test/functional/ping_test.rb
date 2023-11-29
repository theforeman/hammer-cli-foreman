# frozen_string_literal: true

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

    it 'includes cache status if foreman reports it' do
      ping_results['results']['foreman']['cache'] = {
        'servers' => [
          {
            'status' => 'ok',
            'duration_ms' => 5
          }
        ]
      }
      api_expects(:ping, :ping, 'Ping').returns(ping_results)

      output = OutputMatcher.new(
        [
          'cache:',
          '    servers:',
          '     1) Status:          ok',
          '        Server Response: 5'
        ]
      )

      expected_result = success_result(output)
      result = run_cmd(cmd)
      assert_cmd(expected_result, result)
    end

    it 'returns 1 if one of the services failed and shows unrecognized services' do
      ping_results['results']['new_plugin'] = {
        'services' => {
          'first' => {
            'status' => 'FAIL'
          },
          'second' => {
            'status' => 'ok'
          }
        },
        'status' => 'FAIL'
      }
      api_expects(:ping, :ping, 'Ping').returns(ping_results)

      expected_result = CommandExpectation.new
      expected_result.expected_out = OutputMatcher.new(
        [
          'database:',
          '    Status:          ok',
          '    Server Response: Duration: 0ms'
        ]
      )
      expected_result.expected_err =
        ['1 more service(s) failed, but not shown:',
         'first',
         ''].join("\n")
      expected_result.expected_exit_code = 1
      result = run_cmd(cmd)
      assert_cmd(expected_result, result)
    end
  end
end
