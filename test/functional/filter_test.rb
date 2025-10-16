# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')

describe 'filter' do
  def api_expects_filter_info(options)
    api_expects(:filters, :show, 'Get filter info').with_params(
      id: '1'
    ).returns(@filter)
  end

  def taxonomy_usage_error(action, cmd)
    usage_error_result(
      cmd,
      'Organizations and locations can be set only for overriding filters.',
      "Could not #{action} the permission filter"
    )
  end

  def assert_update_success(result)
    assert_cmd(success_result("Permission filter for [User] updated.\n"), result)
  end

  describe 'create' do
    before do
      @cmd = %w[filter create]
    end

    it 'should create a filter' do
      params = ['--role-id=1', '--permission-ids=[1]']

      api_expects(:filters, :create) do |params|
        (params['filter']['role_id'] == '1') &&
        (params['filter']['permission_ids'] == [1])
      end

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Permission filter for [%<resource_type_label>s] created.\n"), result)
    end
  end

  describe 'list' do
    before do
      @cmd = %w[filter list]
      @filters = [{
        id: 1,
        resource_type: 'Architecture',
        search: 'none',
        unlimited?: true,
        override?: false,
        role: { name: 'Manager', id: 2, description: 'Role granting all available permissions.', origin: 'foreman' },
        permissions: 'view_architectures'
      }]
    end

    it 'should return a list of filters' do
      api_expects(:filters, :index, 'List filters').returns(@filters)

      output = IndexMatcher.new([
                                  ['ID', 'RESOURCE TYPE', 'SEARCH', 'ROLE', 'PERMISSIONS'],
                                  ['1', 'Architecture', 'none', 'Manager', 'view_architectures']
                                ])
      expected_result = success_result(output)

      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end
  end

  describe 'delete' do
    before do
      @cmd = %w(filter delete)
    end

    it 'should print error missing argument id' do
      expected_result = "Could not delete the permission filter:\n  Missing arguments for '--id'.\n"

      api_expects_no_call

      result = run_cmd(@cmd)
      assert_match(expected_result, result.err)
    end

    it 'should delete a filter' do
      params = ['--id=1']

      api_expects(:filters, :destroy, 'Delete a filter').with_params(id: '1')

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Permission filter deleted.\n"), result)
    end
  end
end
