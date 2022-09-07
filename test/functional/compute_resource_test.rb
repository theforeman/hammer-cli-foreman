require File.join(File.dirname(__FILE__), 'test_helper')

describe 'compute-resource' do
  let(:base_cmd) { ['compute-resource'] }
  let(:base_params) { ['--id=1'] }
  let(:compute_resource) do
    {
     :id => 1,
     :name => 'resource'
    }
  end

  describe 'create' do
    before do
      @cmd = %w(compute-resource create)
    end

    let :options_missing_error do
      ['Could not create the compute resource:',
       '  Error: Options --name, --provider are required.',
       '  ',
       "  See: 'hammer compute-resource create --help'.",
       ''
      ].join("\n")
    end

    it 'should print error on missing options --name, --provider' do
      params = []

      expected_result = CommandExpectation.new
      expected_result.expected_err = options_missing_error
      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      api_expects_no_call

      result = run_cmd(@cmd + params)

      assert_cmd(expected_result, result)
    end

    it 'should print error for incorrect/invalid --provider option' do
      params = %w(--provider=unknown --name=new)
      expected_result = CommandExpectation.new
      expected_result.expected_err = "Could not create the compute resource:\n  incorrect/invalid --provider option\n"
      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      api_expects_no_call

      result = run_cmd(@cmd + params)

      assert_cmd(expected_result, result)
    end

    describe 'associate VMs to hosts' do
      it 'successful associate vms to hosts' do
        expected_result = success_result("Virtual machines have been associated.\n")
        api_expects(:compute_resources, :associate, 'Associate VMs') do |p|
          p['id'] == '1'
        end
        result = run_cmd(%w(compute-resource associate-vms --id 1))
        assert_cmd(expected_result, result)
      end
    end
   

    it 'should print error for blank --provider option' do
      params = %w(--provider= --name=new'')
      expected_result = CommandExpectation.new
      expected_result.expected_err = "Could not create the compute resource:\n  incorrect/invalid --provider option\n"
      expected_result.expected_exit_code = HammerCLI::EX_USAGE
      api_expects_no_call

      result = run_cmd(@cmd + params)

      assert_cmd(expected_result, result)
    end

    it 'should print error on missing --url' do
      params = %w(--name=my-libvirt --provider=LibVirt)

      expected_result = CommandExpectation.new
      expected_result.expected_err =
        ['Could not create the compute resource:',
         '  Error: Options --name, --provider, --url are required.',
         '  ',
         "  See: 'hammer compute-resource create --help'.",
         ''
        ].join("\n")

      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      api_expects_no_call

      result = run_cmd(@cmd + params)

      assert_cmd(expected_result, result)
    end

    it 'should create a compute-resource' do
      params = %w(--name=my-libvirt --provider=LibVirt --url=qemu+ssh://root@test.foreman.com)

      api_expects(:compute_resources, :create, 'Create Compute Resource') do |params|
        (params['compute_resource']['name'] == 'my-libvirt') &&
          (params['compute_resource']['provider'] == 'LibVirt') &&
          (params['compute_resource']['url'] == 'qemu+ssh://root@test.foreman.com')
      end

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Compute resource created.\n"), result)
    end

    it 'should create a compute-resource ovirt' do
      params = %w(--name=test-ovirt
                  --provider=ovirt
                  --url=https://ovirt.example.com/ovirt-engine/api
                  --user=foreman
                  --password=changeme
                  --datacenter=ovirt.example.com)

      api_expects(:compute_resources, :create, 'Create Compute Resource') do |params|
        (params['compute_resource']['name'] == 'test-ovirt') &&
          (params['compute_resource']['provider'] == 'ovirt') &&
          (params['compute_resource']['url'] == 'https://ovirt.example.com/ovirt-engine/api') &&
          (params['compute_resource']['user'] == 'foreman') &&
          (params['compute_resource']['password'] == 'changeme') &&
          (params['compute_resource']['datacenter'] == 'ovirt.example.com')
      end

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Compute resource created.\n"), result)
    end


    it 'should create a compute-resource ovirt with custom public key' do
      tempfile = Tempfile.new('ca.pem')
      tempfile << 'test data'
      tempfile.close
      params = %W(--name=test-ovirt
                  --provider=ovirt
                  --url=https://ovirt.example.com/ovirt-engine/api
                  --user=foreman
                  --password=changeme
                  --datacenter=ovirt.example.com
                  --public-key-path=#{tempfile.path})

      api_expects(:compute_resources, :create, 'Create Compute Resource') do |params|
        (params['compute_resource']['name'] =='test-ovirt') &&
            (params['compute_resource']['provider'] == 'ovirt') &&
            (params['compute_resource']['url'] == 'https://ovirt.example.com/ovirt-engine/api') &&
            (params['compute_resource']['user'] == 'foreman') &&
            (params['compute_resource']['password'] == 'changeme') &&
            (params['compute_resource']['datacenter'] == 'ovirt.example.com' &&
            (params['compute_resource']['public_key'] == 'test data'))
      end
      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Compute resource created.\n"), result)
    end
end

  describe 'clusters' do
    let(:cmd) { base_cmd << 'clusters' }
    let(:cluster1) { { id: 1, name: 'cluster1' } }
    let(:cluster2) { { id: 2, name: 'cluster2' } }
    let(:clusters) { [cluster1, cluster2] }

    it 'lists available clusters for a compute resource' do
      api_expects(:compute_resources, :available_clusters, 'clusters').with_params(
        'id' => '1'
      ).returns(index_response(clusters))

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 cluster1],
          %w[2 cluster2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'networks' do
    let(:cmd) { base_cmd << 'networks' }
    let(:network1) { { id: 1, name: 'network1' } }
    let(:network2) { { id: 2, name: 'network2' } }
    let(:networks) { [network1, network2] }

    it 'lists available networks for a compute resource' do
      api_expects(:compute_resources, :available_networks, 'networks').with_params(
        'id' => '1'
      ).returns(index_response(networks))

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 network1],
          %w[2 network2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'vnic profiles' do
    let(:cmd) { base_cmd << 'vnic-profiles' }
    let(:vnic_profile_1) { { id: 1, name: 'network1', network: 2 } }
    let(:vnic_profile_2) { { id: 2, name: 'network2', network: 2 } }
    let(:vnic_profiles) { [vnic_profile_1, vnic_profile_2] }

    it 'lists available vnic profiles for a compute resource' do
      api_expects(:compute_resources, :available_vnic_profiles, 'vnic-profiles').with_params(
          'id' => '1'
      ).returns(index_response(vnic_profiles))

      output = IndexMatcher.new(
          [
              ['VNIC PROFILE ID', 'NAME', 'NETWORK ID'],
              ['1', 'network1','2'],
              ['2', 'network2','2']
          ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'images' do
    let(:cmd) { base_cmd << 'images' }
    let(:image1) { { uuid: 1, name: 'image1' } }
    let(:image2) { { uuid: 2, name: 'image2' } }
    let(:images) { [image1, image2] }

    it 'lists available images for a compute resource' do
      api_expects(:compute_resources, :available_images, 'images').with_params(
        'id' => '1'
      ).returns(index_response(images))

      output = IndexMatcher.new(
        [
          %w[UUID NAME],
          %w[1 image1],
          %w[2 image2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'flavors' do
    let(:cmd) { base_cmd << 'flavors' }
    let(:flavor1) { { id: 1, name: 'flavor1' } }
    let(:flavor2) { { id: 2, name: 'flavor2' } }
    let(:flavors) { [flavor1, flavor2] }

    it 'lists available flavors for a compute resource' do
      api_expects(:compute_resources, :available_flavors, 'flavors').with_params(
        'id' => '1'
      ).returns(index_response(flavors))

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 flavor1],
          %w[2 flavor2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'folders' do
    let(:cmd) { base_cmd << 'folders' }
    let(:folder1) { { id: 1, name: 'folder1' } }
    let(:folder2) { { id: 2, name: 'folder2' } }
    let(:folders) { [folder1, folder2] }

    it 'lists available folders for a compute resource' do
      api_expects(:compute_resources, :available_folders, 'folders').with_params(
        'id' => '1'
      ).returns(index_response(folders))

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 folder1],
          %w[2 folder2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'zones' do
    let(:cmd) { base_cmd << 'zones' }
    let(:zone1) { { id: 1, name: 'zone1' } }
    let(:zone2) { { id: 2, name: 'zone2' } }
    let(:zones) { [zone1, zone2] }

    it 'lists available zones for a compute resource' do
      api_expects(:compute_resources, :available_zones, 'zones').with_params(
        'id' => '1'
      ).returns(index_response(zones))

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 zone1],
          %w[2 zone2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'resource_pools' do
    let(:cmd) { base_cmd << 'resource-pools' }
    let(:params) { base_params + ['--cluster-id=1'] }
    let(:resource_pool1) { { id: 1, name: 'resource_pool1' } }
    let(:resource_pool2) { { id: 2, name: 'resource_pool2' } }
    let(:resource_pools) { [resource_pool1, resource_pool2] }

    it 'lists available resource_pools for a compute resource' do
      api_expects(:compute_resources, :available_resource_pools, 'resource-pools').with_params(
        'id' => '1', 'cluster_id' => '1'
      ).returns(index_response(resource_pools))

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 resource_pool1],
          %w[2 resource_pool2]
        ]
      )
      expected_result = success_result(output)
      expected_result.expected_err = "Warning: Option --cluster-id is deprecated. Use --cluster-name instead\n"

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'lists available resource_pools for a compute resource with updated cluster_name param' do
      api_expects(:compute_resources, :available_resource_pools, 'resource-pools').with_params(
        'id' => '1', 'cluster_id' => 'test%2Ftest1'
      ).returns(index_response(resource_pools))

      cluster_param = base_params + ['--cluster-name=test/test1']

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 resource_pool1],
          %w[2 resource_pool2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + cluster_param)
      assert_cmd(expected_result, result)
    end
  end

  describe 'storage_domains' do
    let(:cmd) { base_cmd << 'storage-domains' }
    let(:storage_domain1) { { id: 1, name: 'storage_domain1' } }
    let(:storage_domain2) { { id: 2, name: 'storage_domain2' } }
    let(:storage_domains) { [storage_domain1, storage_domain2] }

    it 'lists available storage_domains for a compute resource' do
      api_expects(:compute_resources, :available_storage_domains, 'storage-domains').with_params(
        'id' => '1'
      ).returns(index_response(storage_domains))

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 storage_domain1],
          %w[2 storage_domain2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'storage_pods' do
    let(:cmd) { base_cmd << 'storage-pods' }
    let(:storage_pod1) { { id: 1, name: 'storage_pod1' } }
    let(:storage_pod2) { { id: 2, name: 'storage_pod2' } }
    let(:storage_pods) { [storage_pod1, storage_pod2] }

    it 'lists available storage_pods for a compute resource' do
      api_expects(:compute_resources, :available_storage_pods, 'storage-pods').with_params(
        'id' => '1'
      ).returns(index_response(storage_pods))

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 storage_pod1],
          %w[2 storage_pod2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'security_groups' do
    let(:cmd) { base_cmd << 'security-groups' }
    let(:security_group1) { { id: 1, name: 'security_group1' } }
    let(:security_group2) { { id: 2, name: 'security_group2' } }
    let(:security_groups) { [security_group1, security_group2] }

    it 'lists available security_groups for a compute resource' do
      api_expects(:compute_resources, :available_security_groups, 'security-groups').with_params(
        'id' => '1'
      ).returns(index_response(security_groups))

      output = IndexMatcher.new(
        [
          %w[ID NAME],
          %w[1 security_group1],
          %w[2 security_group2]
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + base_params)
      assert_cmd(expected_result, result)
    end
  end
end
