require File.join(File.dirname(__FILE__), 'test_helper')
describe "parameters" do

  describe "create values" do
    before do
      @cmd = ["compute-profile", "values", "create"]
    end

    it "should print error on missing --compute-profile-id or --compute-profile" do
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not set the compute profile attributes"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource" do
      params = ['--compute-profile-id=1']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-resource-id, --compute-resource is required.",
        "Could not set the compute profile attributes"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe "update values" do
    before do
      @cmd = ["compute-profile", "values", "update"]
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

    it "values update - should print error on missing --compute-profile-id or --compute-profile" do
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not update the compute profile attributes"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "values update - should print error on missing --compute-resource-id or --compute-resource" do
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


    it "values update - should update attributes" do
      params = ['--compute-profile-id=1', '--compute-resource-id=1', '--compute-attributes', 'cores=1']

      api_expects(:compute_profiles, :show) do |par|
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
      @cmd = ["compute-profile", "values", "add-volume"]
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
      params= ['--volume', 'size_gb=1']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not create volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource" do
      params = ['--compute-profile=A', '--volume', 'size_gb=1']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-resource-id, --compute-resource is required.",
        "Could not create volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end


    it "should print error on compute profile value does not exist" do
      params = ['--compute-profile-id=1', '--compute-resource-id=15', '--volume', 'size_gb=1']
      expected_result = CommandExpectation.new
      expected_result.expected_err = "Could not create volume:\n  Compute profile value to update does not exist yet; it needs to be created first\n"
      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on unknown compute profile" do
      params = ['--compute-profile-id=200', '--compute-resource-id=1', '--volume', 'size_gb=1']
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
      params = ['--compute-profile-id=1', '--compute-resource-id=1', '--volume', 'size_gb=1']

      api_expects(:compute_profiles, :show) do |par|
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
        @cmd = ["compute-profile", "values", "update-volume"]
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

      it "should print error on missing --volume" do
        expected_result = usage_error_result(
          @cmd,
          "Option '--volume' is required.",
          "Could not update volume"
        )

        api_expects_no_call
        result = run_cmd(@cmd)
        assert_cmd(expected_result, result)
      end

      it "should print error on missing --volume-id" do
        params = ['--volume', 'compute_name="compute"']
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
        params = ['--volume', 'compute_name="eth1"', '--volume-id=1']
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
        params = ['--compute-profile-id=1', '--compute-resource-id=1', '--volume-id=1', '--volume', 'size_gb=1']

        api_expects(:compute_profiles, :show) do |par|
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
      @cmd = ["compute-profile", "values", "remove-volume"]
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
      params = ['--volume-id=1']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not remove volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource" do
      params = ['--compute-profile=A', '--volume-id=1']
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
      params = ['--compute-profile-id=1', '--compute-resource-id=1']
      expected_result = usage_error_result(
        @cmd,
        "Option '--volume-id' is required.",
        "Could not remove volume"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should remove volume" do
      params = ['--compute-profile-id=1', '--compute-resource-id=1', '--volume-id=1']

      api_expects(:compute_profiles, :show) do |par|
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
      @cmd = ["compute-profile", "values", "add-interface"]
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
      param = ['--interface', 'name=eth0']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not create interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd+ param)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource." do
      params = ['--compute-profile=A', '--interface', 'name=eth0']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-resource-id, --compute-resource is required.",
        "Could not create interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --interface" do
      params = ['--compute-profile=A', '--compute-resource=B']
      expected_result = usage_error_result(
        @cmd,
        "Option '--interface' is required.",
        "Could not create interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on compute profile value does not exist" do
      params = ['--compute-profile-id=1', '--compute-resource-id=15', '--interface', 'name=eth0']
      expected_result = CommandExpectation.new
      expected_result.expected_err = "Could not create interface:\n  Compute profile value to update does not exist yet; it needs to be created first\n"
      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on unknown compute profile" do
      params = ['--compute-profile-id=200', '--compute-resource-id=1', '--interface', 'name=eth0']
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
      params = [ '--interface', 'name=eth0', '--compute-profile-id=1', '--compute-resource-id=1']
      api_expects(:compute_profiles, :show) do |par|
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
      @cmd = ["compute-profile", "values", "update-interface"]
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

    it "should print error on missing --interface" do
      expected_result = usage_error_result(
        @cmd,
        "Option '--interface' is required.",
        "Could not update interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --interface-id" do
      params = ['--interface', 'compute_name="compute"']
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
      params = ['--interface', 'compute_name="eth1"', '--interface-id=1']
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
      params = ['--compute-profile-id=1', '--compute-resource-id=1', '--interface-id=1', '--interface', 'compute_name=eth0']

      api_expects(:compute_profiles, :show) do |par|
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
      @cmd = ["compute-profile", "values", "remove-interface"]
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
      param = ['--interface-id=1']
      expected_result = usage_error_result(
        @cmd,
        "At least one of options --compute-profile-id, --compute-profile is required.",
        "Could not remove interface"
      )

      api_expects_no_call
      result = run_cmd(@cmd + param)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --compute-resource-id or --compute-resource" do
      params = ['--compute-profile=A', '--interface-id=1']
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
      params = ['--compute-profile-id=1', '--compute-resource-id=1']
      expected_result = usage_error_result(
        @cmd,
        "Option '--interface-id' is required.",
        "Could not remove interface"
      )
      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should remove interface" do
      params = ['--compute-profile-id=1', '--compute-resource-id=1', '--interface-id=1']

      api_expects(:compute_profiles, :show) do |par|
        par['id'] == 1
      end.returns(@compute_profile)

      api_expects(:compute_attributes, :update) do |par|
        par['id'] == 2
      end.returns(@compute_attribute)
      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Interface was removed.\n"), result)
    end
  end
end
