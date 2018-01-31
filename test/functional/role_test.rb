require File.join(File.dirname(__FILE__), 'test_helper')

describe 'role' do
  describe 'clone' do
    before do
      @cmd = %w(role clone)
    end

    it 'should print error on missing --id' do
      params = ['--new-name=zzz']

      expected_result = CommandExpectation.new
      expected_result.expected_err =
        ['Could not clone the user role:',
         "  Missing arguments for 'id'",
         ''].join("\n")
      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      api_expects_no_call

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'should print error on missing --new-name' do
      params = ['--id=1']

      expected_result = usage_error_result(
        @cmd,
        'Option --new-name is required.',
        'Could not clone the user role')

      api_expects_no_call

      result = run_cmd(@cmd + params)

      assert_cmd(expected_result, result)
    end

    it 'should clone a role by id' do
      params = ['--id=1', '--new-name=zzz']

      api_expects(:roles, :clone, 'Clone role').with_params({
        'id' => '1', 'role' => {'name' => 'zzz'}, 'name' => 'zzz'
      })

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("User role cloned.\n"), result)
    end

    it 'should clone a role by name' do
      params = ['--name=old', '--new-name=zzz']

      api_expects_search(:roles, { :name => 'old' }, 'Attempt find role').returns(
        index_response(
          [{
              'name' => 'old',
              'id' => 1
          }]))

      api_expects(:roles, :clone, 'Clone role').with_params({
        'id' => 1, 'role' => {'name' => 'zzz'}, 'name' => 'zzz'
      })

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("User role cloned.\n"), result)
    end
  end
end
