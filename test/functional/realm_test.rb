require File.join(File.dirname(__FILE__), 'test_helper')

describe 'realm' do
  describe 'list' do
    before do
      @cmd = %w[realm list]
      @realms =
        [{
           id: 1,
           name: 'test-realm' }]
    end

    it 'should return a list of realms' do
      api_expects(:realms, :index, 'List realms').returns(@realms)

      result = run_cmd(@cmd)
      _(result.exit_code).must_equal HammerCLI::EX_OK
    end
  end

  describe 'info' do
    before do
      @cmd = %w[realm info]
      @realm = {
          id: 1,
          name: 'test-realm'
      }
    end

    it 'should return a realm' do
      params = ['--id=1']
      api_expects(:realms, :show, 'Show realm').returns(@realm)

      result = run_cmd(@cmd + params)
      _(result.exit_code).must_equal HammerCLI::EX_OK
    end
  end

  describe 'create' do
    before do
      @cmd = %w[realm create]
    end

    it 'should print error on missing --name, --realm-proxy-id, --realm-type' do
      expected_result = "Could not create the realm:\n  Missing arguments for '--name', '--realm-proxy-id', '--realm-type'.\n"

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_match(expected_result, result.err)
    end

    it 'should create a realm' do
      params = %w[--name=test-realm --realm-proxy-id=12345 --realm-type=FreeIPA]

      api_expects(:realms, :create, 'Create a realm') do |params|
        (params['realm']['name'] == 'test-realm' &&
         params['realm']['realm_proxy_id'] == 12345 &&
         params['realm']['realm_type'] == 'FreeIPA')
      end

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Realm [%{name}] created.\n"), result)
    end
  end

  describe 'delete' do
    before do
      @cmd = %w[realm delete]
    end

    it 'should delete a realm' do
      params = ['--id=1']

      api_expects(:realms, :destroy, 'Delete realm').with_params(id: '1')

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Realm [%{name}] deleted.\n"), result)
    end
  end

  describe 'update' do
    before do
      @cmd = %w[realm update]
      @realm = {
        id: 1,
        name: 'test-realm-update'
      }
    end

    it 'should update a realm' do
      params = %w[--id=1 --new-name=test-realm-update]

      api_expects(:realms, :update, 'Update a realm') do |params|
        (params['id'] == '1' &&
         params['realm']['name'] == 'test-realm-update')
      end

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Realm [%{name}] updated.\n"), result)
    end
  end
end
