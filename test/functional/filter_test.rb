require File.join(File.dirname(__FILE__), 'test_helper')

describe 'filter' do
  def api_expects_filter_info(options)
    override = !!options[:override]
    api_expects(:filters, :show, 'Get filter info').with_params({
      :id => '1'
    }).returns(@filter.merge('override?' => override))
  end

  def taxonomy_usage_error(action, cmd)
    usage_error_result(
      cmd,
      'Organizations and locations can be set only for overriding filters.',
      "Could not #{action} the permission filter")
  end

  def assert_update_success(result)
    assert_cmd(success_result("Permission filter for [User] updated.\n"), result)
  end

  describe 'create' do
    before do
      @cmd = %w(filter create)
    end

    it 'prints error when taxonomies are used for a not-overriding filter' do
      params = ['--organization-ids=1,2', '--location-ids=3,4', '--override=false']

      api_expects_no_call

      result = run_cmd(@cmd + params)
      assert_cmd(taxonomy_usage_error('create', @cmd), result)
    end
  end

  describe 'update' do
    before do
      @cmd = %w(filter update)
      @filter = {
        "search" => nil,
        "resource_type" => "User",
        "unlimited?" => false,
        "created_at" => "2017-07-18 14:34:09 UTC",
        "updated_at" => "2017-07-18 14:34:09 UTC",
        "override?" => true,
        "id" => 404,
        "role" => {
          "name" => "Some Role",
          "id" => 28,
          "description" => "Description\nof the new\nrole",
          "origin" => nil
        },
        "permissions" => [{
            "name" => "view_users",
            "id" => 164,
            "resource_type" => "User"
        }],
        "locations" => [{
          "id" => 28,
          "name" => "location74",
          "title" => "location74",
          "description" => nil
        }],
        "organizations" => [{
          "id" => 27,
          "name" => "organization74",
          "title" => "organization74",
          "description" => nil
        }]
      }
    end

    it 'resets taxonomies when a filter is not-overriding' do
      params = ['--id=1']

      api_expects_filter_info(:override => false)
      api_expects(:filters, :update, 'Update the filter').with_params({
        'filter' => {
          'organization_ids' => [],
          'location_ids' => []
        }
      }).returns(@filter)

      assert_update_success(run_cmd(@cmd + params))
    end

    it 'resets taxonomies when switching a filter to not-overriding' do
      params = ['--id=1', '--override=false']

      api_expects(:filters, :update, 'Update the filter').with_params({
        'filter' => {
          'organization_ids' => [],
          'location_ids' => []
        }
      }).returns(@filter)

      assert_update_success(run_cmd(@cmd + params))
    end

    it 'can add taxonomies when a filter is overriding' do
      params = ['--id=1', '--organization-ids=1,2', '--location-ids=3,4']

      api_expects_filter_info(:override => true)
      api_expects(:filters, :update, 'Update the filter').with_params({
        'filter' => {
          'organization_ids' => ['1', '2'],
          'location_ids' => ['3', '4']
        }
      }).returns(@filter)

      assert_update_success(run_cmd(@cmd + params))
    end

    it 'can add taxonomies when switching a filter to overriding' do
      params = ['--id=1', '--organization-ids=1,2', '--location-ids=3,4', '--override=true']

      api_expects(:filters, :update, 'Update the filter').with_params({
        'filter' => {
          'organization_ids' => ['1', '2'],
          'location_ids' => ['3', '4']
        }
      }).returns(@filter)

      assert_update_success(run_cmd(@cmd + params))
    end

    it 'prints error when taxonomies are used on not-overriding' do
      params = ['--id=1', '--organization-ids=1,2', '--location-ids=3,4']

      api_expects_filter_info(:override => false)

      result = run_cmd(@cmd + params)
      assert_cmd(taxonomy_usage_error('update', @cmd), result)
    end

    it 'prints error when taxonomies are used when switching a filter to not-overriding' do
      params = ['--id=1', '--organization-ids=1,2', '--location-ids=3,4', '--override=false']

      api_expects_no_call

      result = run_cmd(@cmd + params)
      assert_cmd(taxonomy_usage_error('update', @cmd), result)
    end
  end
end
