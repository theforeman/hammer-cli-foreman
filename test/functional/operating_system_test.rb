# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')

describe 'operating_system' do
  describe 'list' do
    before do
      @cmd = %w[os list]
      @operating_system = [{
                          id: 1,
                          release_name: 'Redhat 7',
                          family: 'Redhat',
                        }]
    end

    it 'should return a list of operating system' do
      api_expects(:operatingsystems, :index, 'List operating systems').returns(@operating_system)

      output = IndexMatcher.new([
                                  ['ID', 'RELEASE NAME', 'FAMILY'],
                                  ['1', 'Redhat 7', 'Redhat']
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
      api_expects(:operatingsystems, :index, 'List operating systems').returns(@operating_system)

      result = run_cmd(@cmd, { use_defaults: true, defaults: defaults })
      _(result.exit_code).must_equal HammerCLI::EX_OK
    end
  end
end


