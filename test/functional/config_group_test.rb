# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')

describe 'config_group' do
  describe 'list' do
    before do
      @cmd = %w[config-group list]
      @config_groups = [{
                          id: 1,
                          name: 'config-group-test',
                        }]
    end

    it 'should return a list of config groups' do
      api_expects(:config_groups, :index, 'List config groups').returns(@config_groups)

      output = IndexMatcher.new([
                                  %w[ID NAME],
                                  %w[1 config-group-test]
                                ])
      expected_result = success_result(output)

      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it 'should run list command with defaults' do
      providers = { 'foreman' => HammerCLIForeman::Defaults.new(api_connection({}, '2.1')) }
      defaults = HammerCLI::Defaults.new(
        {
          organization_id: {
            provider: 'foreman'
          },
          location_id: {
            provider: 'foreman'
          }
        }
      )
      defaults.stubs(:write_to_file).returns(true)
      defaults.stubs(:providers).returns(providers)
      api_expects(:config_groups, :index, 'List config groups').returns(@config_groups)

      result = run_cmd(@cmd, { use_defaults: true, defaults: defaults })
      _(result.exit_code).must_equal HammerCLI::EX_OK
    end
  end
end


