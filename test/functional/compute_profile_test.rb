require File.join(File.dirname(__FILE__), 'test_helper')
describe "parameters" do

  describe "create compute profile" do
    before do
      @cmd = ["compute-profile", "create"]
    end
    it 'should create a compute-profile' do
      params = ['--name=newProfile']
      api_expects(:compute_profiles, :create, 'Create Compute Profile') do |params|
        (params['compute_profile']['name'] == 'newProfile')
      end
      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Compute profile created.\n"), result)
    end
  end

  describe "update compute profile" do
    before do
        @cmd = ["compute-profile","update"]
        @compute_profile =
          {
            "id": 1,
            "name": "profile2",
            "compute_attributes": [{
                                     "id": 2,
                                     "compute_resource_id": 3,
                                     "compute_resource_name": "bla",
                                     "provider_friendly_name": "oVirt",
                                     "compute_profile_id": 1,
                                     "compute_profile_name": "profile2",
                                   }]
          }
    end
    it 'update compute profile name' do
      params = ['--id=1', '--new-name=profile2']
      api_expects(:compute_profiles, :update, 'Update the compute profile').with_params(
        { 'compute_profile' => { 'name' => 'profile2' } }
      ).returns(@compute_profile)
      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Compute profile updated.\n"), result)
    end

    it 'updates nothing without profile related parameters' do
      params = %w[--id=1]
      api_expects(:compute_profiles, :update, 'Update profile with no params').returns({})

      expected_result = success_result("Nothing to update.\n")

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

  end

  describe "delete compute profile" do
    before do
      @cmd = ["compute-profile","delete"]
      @compute_profile =
        {
          "id": 3,
          "name": "profile3",
          "compute_attributes": [{
                                   "id": 4,
                                   "compute_resource_id": 3,
                                   "compute_resource_name": "bla",
                                   "provider_friendly_name": "oVirt",
                                   "compute_profile_id": 3,
                                   "compute_profile_name": "profile3",
                                 }]
        }
    end
    it 'delete compute profile' do
      params = ['--id=3']
      api_expects(:compute_profiles, :destroy, :id => 3).returns({})
      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Compute profile deleted.\n"), result)
    end


    it "should print error on missing --name or --id" do
      params = []

      expected_result = usage_error_result(
        @cmd,
        "At least one of options --name, --id is required.",
        "Could not delete the Compute profile"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error when the compute profile doesn't exist" do
      params = ['--id=200']

      expected_result = not_found_error_result(
        @cmd,
        "Resource compute_profile not found by id '200'",
        "Could not delete the Compute profile"
      )
      expected_message = "{ \"error\": {\"message\": \"Error: Resource compute_profile not found by id '200'\" }}"
      response = HammerCLIForeman.foreman_api.api.send(:create_fake_response, 404,
                                                       expected_message, "GET", "http://example.com/", {})
      api_expects(:compute_profiles, :destroy, :id => 3).raises(RestClient::NotFound, response)
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'list' do
    before do
      @cmd = %w[compute-profile list]
      @compute_profiles = [{
                          id: 1,
                          name: '1-Small',
                        }]
    end

    it 'should return a list of compute profiles' do
      api_expects(:compute_profiles, :index, 'List compute profiles').returns(@compute_profiles)

      output = IndexMatcher.new([
                                  %w[ID NAME],
                                  %w[1 1-Small]
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
      api_expects(:users, :index, 'Find user').with_params(search: 'login=admin').returns(index_response([{ 'default_organization' => { 'id' => 2 } }]))
      api_expects(:users, :index, 'Find user').with_params(search: 'login=admin').returns(index_response([{ 'default_location' => { 'id' => 1 } }]))
      api_expects(:compute_profiles, :index, 'List compute profiles').returns(@compute_profiles)

      result = run_cmd(@cmd, { use_defaults: true, defaults: defaults })
      _(result.exit_code).must_equal HammerCLI::EX_OK
    end
  end

end
