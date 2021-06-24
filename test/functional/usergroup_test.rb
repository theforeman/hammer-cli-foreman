# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')

describe 'user-group' do
  describe 'list' do
    before do
      @cmd = %w[user-group list]
      @user_groups = [{
                          id: 1,
                          name: 'test-user-group',
                          admin: 'yes',
                        }]
    end

    it 'should return a list of user groups' do
      api_expects(:usergroups, :index, 'List user groups').returns(@user_groups)

      output = IndexMatcher.new([
                                  %w[ID NAME ADMIN],
                                  %w[1 test-user-group yes]
                                ])
      expected_result = success_result(output)

      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it 'should run list command with defaults' do
      providers = { 'foreman' => HammerCLIForeman::Defaults.new(api_connection({}, '2.5')) }
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
      api_expects(:users, :index, 'Find user').with_params(search: 'login=admin').returns(index_response([{ 'default_organization' => { 'id' => 2 } }]))
      api_expects(:users, :index, 'Find user').with_params(search: 'login=admin').returns(index_response([{ 'default_location' => { 'id' => 1 } }]))
      api_expects(:usergroups, :index, 'List user groups').returns(@user_groups)

      result = run_cmd(@cmd, { use_defaults: true, defaults: defaults })
      _(result.exit_code).must_equal HammerCLI::EX_OK
    end
  end
end


