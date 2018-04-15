require File.join(File.dirname(__FILE__), 'test_helper')
describe "parameters" do

  describe "set-attributes" do
    before do
      @cmd = ["compute-profile", "set-attributes"]
    end

    it "set-attributes - should print error on missing --compute-profile-id or --compute-profile" do
      expected_result = common_error_result(
        @cmd,
        "Could not find compute_profile, please set one of options --compute-profile, --compute-profile-id.",
        "Could not set the compute profile attributes"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource" do
      params = ['--compute-profile-id=1']
      expected_result = common_error_result(
        @cmd,
        "Could not find compute_resource, please set one of options --compute-resource, --compute-resource-id.",
        "Could not set the compute profile attributes"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe "update-attributes" do
    before do
      @cmd = ["compute-profile", "update-attributes"]
      @compute_profile =
        {
          "id" => 1,
          "name" => "profile2",
          "compute_attributes" => [{
                                     "id" => 2,
                                     "compute_resource_id" => 1,
                                     "compute_resource_name" => "bla",
                                     "provider_friendly_name" => "oVirt",
                                     "compute_profile_id" => 1,
                                     "compute_profile_name" => "profile2",
                                     "vm_attrs" => {}
                                   }]
        }
      @compute_attribute =
        {
          "compute_attribute" =>
            {
              "id" => 2, "compute_resource_id" => 1, "compute_resource_name" => "bla",
              "provider_friendly_name" => "oVirt", "compute_profile_id" => 1,
              "compute_profile_name" => "profile2", "vm_attrs" => {"cores" => "1"}
            }
        }
    end

    it "update-attributes - should print error on missing --compute-profile-id or --compute-profile" do
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not update the compute profile attributes"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "update-attributes - should print error on missing --compute-resource-id or --compute-resource" do
      params = ['--compute-profile-id=1']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-resource-id, --compute-resource is required.",
        "Could not update the compute profile attributes"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)

      assert_cmd(expected_result, result)
    end

    it "update-attributes - should print error on missing options" do
      params = ['--compute-profile-id=1', '--compute-resource-id=1']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --interface, --volume, --compute-attributes is required.",
        "Could not update the compute profile attributes"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "update-attributes - should update attributes" do
      params = ['--compute-profile-id=1', '--compute-resource-id=1','--compute-attributes', 'cores=1']

      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_resources, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_attributes, :update) do |par|
        par['id'] == 2
      end.returns(@compute_attribute)

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Compute profile attributes updated.\n"), result)
    end
  end

  describe "add-volume" do
    before do
      @cmd = ["compute-profile", "add-volume"]
      @compute_profile =
        {
          "id" => 1,
          "name" => "profile2",
          "compute_attributes" => [{
                                     "id" => 2,
                                     "compute_resource_id" => 1,
                                     "compute_resource_name" => "bla",
                                     "provider_friendly_name" => "oVirt",
                                     "compute_profile_id" => 1,
                                     "compute_profile_name" => "profile2",
                                     "vm_attrs" => {}
                                   }]
        }
      @compute_attribute = {
        "id" => 2, "compute_resource_id" => 1, "compute_resource_name" => "bla",
        "provider_friendly_name" => "oVirt", "compute_profile_id" => 1, "compute_profile_name" => "profile2",
        "vm_attrs" => {"volumes_attributes" => {"1525004465" => {"size_gb" => "1"}}}
      }

    end

    it "should print error on missing --compute-profile-id or --compute-profile" do
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not create volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource" do
      params = ['--compute-profile=A']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-resource-id, --compute-resource is required.",
        "Could not create volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --set_values" do
      params = ['--compute-profile=A', '--compute-resource=B']
      expected_result = usage_error_result(
        @cmd,
        "Options --set-values are required.",
        "Could not create volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on unknown compute resource" do
      params = ['--compute-profile-id=1', '--compute-resource-id=15', '--set-values','size_gb=1']
      expected_result = not_found_error_result(
        @cmd,
        "Resource compute_resource not found by id '15'",
        "Could not create volume"
      )
      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      expected_message = "{ \"error\": {\"message\": \"Error: Resource compute_resource not found by id '15'\" }}"
      response = HammerCLIForeman.foreman_api.api.send(:create_fake_response, 404,
                                                       expected_message, "GET", "http://example.com/", {})
      api_expects(:compute_resources, :show) do |par|
        par['id'] == 15
      end.raises(RestClient::NotFound, response)
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on unknown compute profile" do
      params = ['--compute-profile-id=200', '--compute-resource-id=1', '--set-values','size_gb=1']
      expected_result = not_found_error_result(
        @cmd,
        "Resource compute_profile not found by id '200'",
        "Could not create volume"
      )
      expected_message = "{ \"error\": {\"message\": \"Error: Resource compute_profile not found by id '200'\" }}"
      response = HammerCLIForeman.foreman_api.api.send(:create_fake_response, 404,
                                                       expected_message, "GET", "http://example.com/", {})
      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 200
      end.raises(RestClient::NotFound, response)

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should add volume" do
      params = ['--compute-profile-id=1' ,'--compute-resource-id=1','--set-values', 'size_gb=1']

      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_resources, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_attributes, :update) do |par|
        par['id'] == 2
      end.returns(@compute_attribute)

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Volume was created.\n"), result)
    end
  end

  describe "update-volume" do
      before do
        @cmd = ["compute-profile", "update-volume"]
        @compute_profile =
          {
            "id" => 1,
            "name" => "profile2",
            "compute_attributes" => [{
                                       "id" => 2,
                                       "compute_resource_id" => 1,
                                       "compute_resource_name" => "bla",
                                       "provider_friendly_name" => "oVirt",
                                       "compute_profile_id" => 1,
                                       "compute_profile_name" => "profile2",
                                       "vm_attrs" => {}
                                     }]
          }
      end

      it "should print error on missing --set-values" do
        expected_result = usage_error_result(
          @cmd,
          "Option '--set-values' is required.",
          "Could not update volume"
        )

        api_expects_no_call
        result = run_cmd(@cmd)
        assert_cmd(expected_result, result)
      end

      it "should print error on missing --volume-id" do
        params = ['--set-values', 'compute_name="compute"']
        expected_result = usage_error_result(
          @cmd,
          "Option '--volume-id' is required.",
          "Could not update volume"
        )

        api_expects_no_call
        result = run_cmd(@cmd + params)
        assert_cmd(expected_result, result)
      end

      it "should print error on missing --compute-resource-id or --compute-resource." do
        params = ['--set-values', 'compute_name="eth1"','--volume-id=1']
        expected_result = usage_error_result(
          @cmd,
          "At least one of options --compute-profile-id, --compute-profile is required.",
          "Could not update volume"
        )

        api_expects_no_call
        result = run_cmd(@cmd + params)
        assert_cmd(expected_result, result)
      end

      it "should update volume" do
        params = ['--compute-profile-id=1','--compute-resource-id=1', '--volume-id=1','--set-values', 'size_gb=1']

        api_expects(:compute_profiles, :show) do |par|
          par['id'] == 1
        end.returns(@compute_profile)

        api_expects(:compute_resources, :show) do |par|
          par['id'] == 1
        end.returns(@compute_profile)

        api_expects(:compute_attributes, :update) do |par|
          par['id'] == 2
        end.returns(@compute_attribute)

        result = run_cmd(@cmd + params)
        assert_cmd(success_result("Volume was updated.\n"), result)
      end
    end

  describe "remove-volume" do
    before do
      @cmd = ["compute-profile", "remove-volume"]
      @compute_profile =
        {
          "id" => 1,
          "name" => "profile2",
          "compute_attributes" => [{
                                     "id" => 2,
                                     "compute_resource_id" => 1,
                                     "compute_resource_name" => "bla",
                                     "provider_friendly_name" => "oVirt",
                                     "compute_profile_id" => 1,
                                     "compute_profile_name" => "profile2",
                                     "vm_attrs" => {"volumes_attributes" => { "1" => {"size_gb"=>"1"}}}
                                   }]
        }
      @compute_attribute =  {
        "id" => 2, "compute_resource_id" => 1, "compute_resource_name" => "bla",
        "provider_friendly_name" => "oVirt", "compute_profile_id" => 1,
        "compute_profile_name" => "profile2", "vm_attrs" => {"volumes_attributes" => {}}
      }
    end

    it "should print error on missing --compute-profile-id or --compute-profile" do
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not remove volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource" do
      params = ['--compute-profile=A']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-resource-id, --compute-resource is required.",
        "Could not remove volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --volume-id" do
      params = ['--compute-profile-id=1','--compute-resource-id=1']
      expected_result = usage_error_result(
        @cmd,
        "Options --volume-id are required.",
        "Could not remove volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should remove volume" do
      params = ['--compute-profile-id=1','--compute-resource-id=1', '--volume-id=1']

      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_resources, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_attributes, :update) do |par|
        par['id'] == 2
      end.returns(@compute_attribute)

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Volume was removed.\n"), result)
    end
  end

  describe "add-interface" do
    before do
      @cmd = ["compute-profile", "add-interface"]
      @compute_profile =
        {
          "id" => 1,
          "name" => "profile2",
          "compute_attributes" => [{
                                   "id" => 2,
                                   "compute_resource_id" => 1,
                                   "compute_resource_name" => "bla",
                                   "provider_friendly_name" => "oVirt",
                                   "compute_profile_id" => 1,
                                   "compute_profile_name" => "profile2",
                                   "vm_attrs" => {}
                                 }]
        }
      @compute_profile2 =
        {
          "id" => 200,
          "name" => "profile2",
          "compute_attributes" => [{
                                     "id" => 2,
                                     "compute_resource_id" => 1,
                                     "compute_resource_name" => "bla",
                                     "provider_friendly_name" => "oVirt",
                                     "compute_profile_id" => 1,
                                     "compute_profile_name" => "profile2",
                                     "vm_attrs" => {}
                                   }]
        }
    end

    it "should print error on missing --compute-profile-id or --compute-profile" do
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not create interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource." do
      params = ['--compute-profile=A']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-resource-id, --compute-resource is required.",
        "Could not create interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --set_values" do
      params = ['--compute-profile=A', '--compute-resource=B']
      expected_result = usage_error_result(
        @cmd,
        "Options --set-values are required.",
        "Could not create interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on unknown compute resource" do
      params = ['--compute-profile-id=1', '--compute-resource-id=15', '--set-values','compute_name=eth0']
      expected_result = not_found_error_result(
        @cmd,
        "Resource compute_resource not found by id '15'",
        "Could not create interface"
      )
      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      expected_message = "{ \"error\": {\"message\": \"Error: Resource compute_resource not found by id '15'\" }}"
      response = HammerCLIForeman.foreman_api.api.send(:create_fake_response, 404,
                                                       expected_message, "GET", "http://example.com/", {})
      api_expects(:compute_resources, :show) do |par|
        par['id'] == 15
      end.raises(RestClient::NotFound, response)
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on unknown compute profile" do
      params = ['--compute-profile-id=200', '--compute-resource-id=1', '--set-values','compute_name=eth0']
      expected_result = not_found_error_result(
        @cmd,
        "Resource compute_profile not found by id '200'",
        "Could not create interface"
      )
      expected_message = "{ \"error\": {\"message\": \"Error: Resource compute_profile not found by id '200'\" }}"
      response = HammerCLIForeman.foreman_api.api.send(:create_fake_response, 404,
                                                       expected_message, "GET", "http://example.com/", {})
      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 200
      end.raises(RestClient::NotFound, response)

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should add interface" do
      params = [ '--set-values', 'compute_name=eth0', '--compute-profile-id=1' ,'--compute-resource-id=1']
      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_resources, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)


      api_expects(:compute_attributes, :update) do |par|
        par['id'] == 2
      end.returns(@compute_attribute)
      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Interface was created.\n"), result)
    end
  end

  describe "update-interface" do
    before do
      @cmd = ["compute-profile", "update-interface"]
      @compute_profile =
        {
          "id" => 1,
          "name" => "profile2",
          "compute_attributes" => [{
                                     "id" => 2,
                                     "compute_resource_id" => 1,
                                     "compute_resource_name" => "bla",
                                     "provider_friendly_name" => "oVirt",
                                     "compute_profile_id" => 1,
                                     "compute_profile_name" => "profile2",
                                     "vm_attrs" => {}
                                   }]
        }
    end

    it "should print error on missing --set-values" do
      expected_result = usage_error_result(
        @cmd,
        "Option '--set-values' is required.",
        "Could not update interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --interface-id" do
      params = ['--set-values', 'compute_name="compute"']
      expected_result = usage_error_result(
        @cmd,
        "Option '--interface-id' is required.",
        "Could not update interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource." do
      params = ['--set-values', 'compute_name="eth1"','--interface-id=1']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not update interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should update interface" do
      params = ['--compute-profile-id=1','--compute-resource-id=1', '--interface-id=1','--set-values', 'compute_name=eth0']

      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_resources, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_attributes, :update) do |par|
        par['id'] == 2
      end.returns(@compute_attribute)

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Interface was updated.\n"), result)
    end
  end

  describe "remove-interface" do
    before do
      @cmd = ["compute-profile", "remove-interface"]
      @compute_profile =
        {
          "id" => 1,
          "name" => "profile2",
          "compute_attributes" => [{
                                     "id" => 2,
                                     "compute_resource_id" => 1,
                                     "compute_resource_name" => "bla",
                                     "provider_friendly_name" => "oVirt",
                                     "compute_profile_id" => 1,
                                     "compute_profile_name" => "profile2",
                                     "vm_attrs" => {"interfaces_attributes" => { "1" => {"compute_name"=>"eth0"}}}
                                   }]
        }
      @compute_attribute =  {
        "id" => 2, "compute_resource_id" => 1, "compute_resource_name" => "bla",
        "provider_friendly_name" => "oVirt", "compute_profile_id" => 1,
        "compute_profile_name" => "profile2", "vm_attrs" => {"interfaces_attributes" => {}}
      }

    end

    it "should print error on missing --compute-profile-id or --compute-profile" do
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not remove interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource" do
      params = ['--compute-profile=A']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-resource-id, --compute-resource is required.",
        "Could not remove interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --interface-id" do
      params = ['--compute-profile-id=1','--compute-resource-id=1']
      expected_result = usage_error_result(
        @cmd,
        "Options --interface-id are required.",
        "Could not remove interface"
      )
      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should remove interface" do
      params = ['--compute-profile-id=1','--compute-resource-id=1', '--interface-id=1']

      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_resources, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_attributes, :update) do |par|
        par['id'] == 2
      end.returns(@compute_attribute)
      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Interface was removed.\n"), result)
    end
  end

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
      params = ['--id=1' ,'--new-name=profile2']
      api_expects(:compute_profiles, :update, 'Update the compute profile').with_params({"name" =>"profile2"}).returns(@compute_profile)
      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Compute profile updated.\n"), result)
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

end
