# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')

describe 'architecture' do
  describe 'list' do
    before do
      @cmd = %w[architecture list]
      @architectures = [{
        id: 1,
        name: 'i386'
      }]
    end

    it 'should return a list of architectures' do
      api_expects(:architectures, :index, 'List architectures').returns(@architectures)

      output = IndexMatcher.new([
                                  %w[ID NAME],
                                  %w[1 i386]
                                ])
      expected_result = success_result(output)

      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it 'should run list command with defaults' do
      providers = { 'foreman' => HammerCLIForeman::Defaults.new(api_connection({}, FOREMAN_VERSION)) }
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
      api_expects(:architectures, :index, 'List architectures').returns(@architectures)

      result = run_cmd(@cmd, { use_defaults: true, defaults: defaults })
      _(result.exit_code).must_equal HammerCLI::EX_OK
    end
  end

  describe 'update' do
    before do
      @cmd = %w[architecture update]
      @architecture = {
        id: 1,
        name: 'x86_64',
      }
    end

    it 'should update an architecture with id' do
      params = %w[--id=1 --new-name=x86_64]
      api_expects(:architectures, :update, 'Update architecture').returns(@architecture)

      expected_result = success_result("Architecture updated.\n")

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'updates nothing without architecture related parameters' do
      params = %w[--id=1]
      api_expects(:architectures, :update, 'Update architecture with no params').returns({})

      expected_result = success_result("Nothing to update.\n")

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

  end
end
