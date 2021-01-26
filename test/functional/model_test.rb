# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')

describe 'model' do
  describe 'list' do
    before do
      @cmd = %w[model list]
      @models = [{
                          id: 1,
                          name: 'model',
                        }]
    end

    it 'should return a list of models' do
      api_expects(:models, :index, 'List models').returns(@models)

      output = IndexMatcher.new([
                                  %w[ID NAME],
                                  %w[1 model]
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
      api_expects(:models, :index, 'List models').returns(@models)

      result = run_cmd(@cmd, { use_defaults: true, defaults: defaults })
      _(result.exit_code).must_equal HammerCLI::EX_OK
    end
  end
end


