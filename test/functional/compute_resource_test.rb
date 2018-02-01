require File.join(File.dirname(__FILE__), 'test_helper')

describe 'compute-resource' do
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
      params = %w(--provider=unknown)

      expected_result = CommandExpectation.new
      expected_result.expected_err = options_missing_error
      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      api_expects_no_call

      result = run_cmd(@cmd + params)

      assert_cmd(expected_result, result)
    end

    it 'should print error for blank --provider option' do
      params = %w(--provider='')

      expected_result = CommandExpectation.new
      expected_result.expected_err = options_missing_error
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
      params = %w(--name=my-libvirt --provider=LibVirt --url=qemu+ssh://root@test.foreman.com")

      api_expects(:compute_resources, :create, 'Create Compute Resource') do |params|
        (params['compute_resource']['name'] = 'libvirt') &&
          (params['compute_resource']['provider'] = 'libvirt') &&
          (params['compute_resource']['url'] = 'qemu+ssh://root@test.foreman.com')
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
        (params['compute_resource']['name'] = 'test-ovirt') &&
          (params['compute_resource']['provider'] = 'ovirt') &&
          (params['compute_resource']['url'] = 'https://ovirt.example.com/ovirt-engine/api') &&
          (params['compute_resource']['user'] = 'foreman') &&
          (params['compute_resource']['password'] = 'changeme') &&
          (params['compute_resource']['datacenter'] = 'ovirt.example.com')
      end

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Compute resource created.\n"), result)
    end
  end
end
