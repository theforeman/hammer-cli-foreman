require File.join(File.dirname(__FILE__), 'test_helper')

describe 'host enc-dump' do
  let(:cmd) { ['host', 'enc-dump'] }
  let(:params) { ['--id=1'] }
  let(:context) { { :adapter => :table } }
  let(:json_dump) do
    JSON.dump(
      {
        :parameters => {
          :foreman_subnets => [],
          :location => 'Default Location',
          :location_title => 'Default Location',
          :organization => 'Default Organization',
          :organization_title => 'Default Organization',
          :domainname => 'testdomain.com',
        },
        :classes => []
      }
    )
  end

  it "prints error or missing --id" do
    expected_result = CommandExpectation.new
    expected_result.expected_err =
      ['Could not retrieve ENC values of the host:',
       "  Missing arguments for '--id'.",
       ''].join("\n")
    expected_result.expected_exit_code = HammerCLI::EX_USAGE

    api_expects_no_call

    result = run_cmd(cmd)
    assert_cmd(expected_result, result)
  end

  it "prints ENC YAML to stdout" do
    expected_result = success_result(YAML.dump(json_dump))

    api_expects(:hosts, :enc, "Dump host's ENC YAML").with_params('id' => '1').returns(json_dump)

    result = run_cmd(cmd + params)
    assert_cmd(expected_result, result)
  end

  it "prints ENC YAML even with other adapter" do
    expected_result = success_result(YAML.dump(json_dump))

    api_expects(:hosts, :enc, "Dump host's ENC YAML").with_params('id' => '1').returns(json_dump)

    result = run_cmd(cmd + params, context)
    assert_cmd(expected_result, result)
  end
end

describe 'host boot' do
  let(:cmd) { ['host', 'boot'] }
  let(:params) { ['--id=1', '--device=pxe'] }
  let(:success_boot) do
    JSON.dump(:action => 'pxe', :result => true)
  end

  it 'boots the host' do
    expected_result = success_result("The host is booting.\n")
    api_expects(:hosts, :boot, 'Interface boots from specified device')
      .with_params('id' => '1', 'device' => 'pxe')
      .returns(success_boot)

    result = run_cmd(cmd + params)
    assert_cmd(expected_result, result)
  end
end

describe 'host reset' do
  let(:cmd) { ['host', 'reset'] }
  let(:params) { ['--id=1'] }
  let(:success_cycle) do
    JSON.dump(:power => true)
  end

  it 'boots the host' do
    expected_result = success_result("Host reset started.\n")
    api_expects(:hosts, :power, 'Run power operation on interface.')
      .with_params('id' => '1', 'power_action' => :cycle)
      .returns(success_cycle)

    result = run_cmd(cmd + params)
    assert_cmd(expected_result, result)
  end
end

describe "host create" do
  let(:cmd) { ["host", "create"] }
  let(:minimal_params_without_hostgroup) { ['--location-id=1', '--organization-id=1', '--name=test'] }
  let(:minimal_params) { ['--hostgroup-id=1'] + minimal_params_without_hostgroup }

  it "accepts hostgroup title" do
    api_expects_search(:hostgroups, { :title => 'test/hg1' }).returns(index_response([{ 'id' => '83' }]))
    api_expects(:hosts, :create, 'Create host with interfaces params') do |par|
      par['host']['hostgroup_id'] == '83'
    end.returns({})

    expected_result = success_result("Host created.\n")

    result = run_cmd(cmd + minimal_params_without_hostgroup + ['--hostgroup-title=test/hg1'])
    assert_cmd(expected_result, result)
  end

  it "passes interface attributes to server" do
    params = ['--interface', 'identifier=eth0,ip=10.0.0.4,primary=true,provision=true']

    api_expects(:hosts, :create, 'Create host with interfaces params') do |par|
      ifces = par['host']['interfaces_attributes']

      ifces.length == 1 &&
      ifces[0]['ip'] == '10.0.0.4' &&
      ifces[0]['identifier'] == 'eth0'
    end.returns({})

    expected_result = success_result("Host created.\n")

    result = run_cmd(cmd + minimal_params + params)
    assert_cmd(expected_result, result)
  end

  it "accepts host parameter attributes" do
    params = ['--parameters', 'param1=value1']

    api_expects(:hosts, :create, 'Create host with parameters') do |par|
      par['host']['host_parameters_attributes'][0]['name'] == 'param1' &&
      par['host']['host_parameters_attributes'][0]['value'] == 'value1'
    end

    expected_result = success_result("Host created.\n")
    result = run_cmd(cmd + minimal_params + params)
    assert_cmd(expected_result, result)
  end

  it "accepts host typed parameter attributes" do
    params = [
      '--typed-parameters',
      'name=par1\,value=1\,parameter_type=integer,name=par2\,value=par2\,parameter_type=string'
    ]

    api_expects(:hosts, :create, 'Create host with typed parameters') do |par|
      par['host']['host_parameters_attributes'][0]['name'] == 'par1' &&
      par['host']['host_parameters_attributes'][0]['value'] == '1' &&
      par['host']['host_parameters_attributes'][0]['parameter_type'] == 'integer' &&
      par['host']['host_parameters_attributes'][1]['name'] == 'par2' &&
      par['host']['host_parameters_attributes'][1]['value'] == 'par2' &&
      par['host']['host_parameters_attributes'][1]['parameter_type'] == 'string'
    end

    expected_result = success_result("Host created.\n")
    result = run_cmd(cmd + minimal_params + params)
    assert_cmd(expected_result, result)
  end

  it "sends empty hash for no interfaces" do
    # For some reason the Foreman replaces empty interfaces_attributes to nil,
    # which causes failure in nested attributes assignment in the host model

    api_expects(:hosts, :create, 'Create host with empty interfaces') do |par|
      par['host']['interfaces_attributes'] == []
    end.returns({})

    expected_result = success_result("Host created.\n")

    result = run_cmd(cmd + minimal_params)
    assert_cmd(expected_result, result)
  end

  it "translates subnet name to id in --interface" do
    subnet = {
      'id' => 83,
      'name' => 'localhost'
    }
    params = ['--interface', 'subnet=localhost']

    api_expects_search(:subnets, {:name => 'localhost'}).returns(index_response([subnet]))
    api_expects(:hosts, :create, 'Create host with subnet id') do |par|
      ifces = par['host']['interfaces_attributes']

      ifces.length == 1 &&
      ifces[0]['subnet'] == nil &&
      ifces[0]['subnet_id'] == 83
      true
    end.returns({})

    expected_result = success_result("Host created.\n")

    result = run_cmd(cmd + minimal_params + params)
    assert_cmd(expected_result, result)
  end

  it "translates domain name to id in --interface" do
    domain = {
      'id' => 32,
      'name' => 'theforeman.org'
    }
    params = ['--interface', 'domain=theforeman.org']

    api_expects_search(:domains, {:name => 'theforeman.org'}).returns(index_response([domain]))
    api_expects(:hosts, :create, 'Create host with domain id') do |par|
      ifces = par['host']['interfaces_attributes']

      ifces.length == 1 &&
      ifces[0]['domain'] == nil &&
      ifces[0]['domain_id'] == 32
    end.returns({})

    expected_result = success_result("Host created.\n")

    result = run_cmd(cmd + minimal_params + params)
    assert_cmd(expected_result, result)
  end

  it "accepts --architecture, --domain, --operatingsystem and --partition-table when no hostgroup is used" do
    params = [
      '--architecture=x86_64',
      '--domain=test.org',
      '--operatingsystem=rhel',
      '--partition-table=default'
    ]

    mock_item = { 'id' => '1' }

    api_expects_search(:architectures,    { :name => 'x86_64' }).returns(index_response([mock_item]))
    api_expects_search(:domains,          { :name => 'test.org' }).returns(index_response([mock_item])).at_least_once
    api_expects_search(:operatingsystems, { :title => 'rhel' }).returns(index_response([mock_item]))
    api_expects_search(:ptables,          { :name => 'default' }).returns(index_response([mock_item]))
    api_expects(:hosts, :create, 'Create host with interfaces params').returns({})

    expected_result = success_result("Host created.\n")

    result = run_cmd(cmd + minimal_params_without_hostgroup + params)
    assert_cmd(expected_result, result)
  end

  it "Creates host in case the image is provided from the hostgroup and hostgroup is not nested" do
    params = ['--name=test',
              '--provision-method=image',
              '--image-id=8' ,
              '--managed=true',
              '--hostgroup-id=1',
              '--organization-id=1',
              '--location-id=1'
    ]

    api_expects(:hostgroups, :show).with_params(
      {}
    ).returns({'compute_resource_name' => "cr", 'compute_resource_id' => 33 })

    api_expects(:images, :show).with_params(
      {"compute_resource_id" => 33, "id" => 8}
    ).returns(results: {'uuid' => '111111'})

    api_expects(:hosts, :create).with_params(
      {"location_id" => 1, "organization_id" => 1, "host" => {"name" => "test", "location_id" => 1, "organization_id" => 1, "hostgroup_id" => 1, "image_id" => 8, "provision_method" => "image", "managed" => true, "compute_attributes" => {"volumes_attributes" => {}, "image_id" => nil}, "build" => true, "enabled" => true, "overwrite" => true, "interfaces_attributes" => []}}
    ).returns(results: {'uuid' => '111111'})

    expected_result = success_result("Host created.\n")
    result = run_cmd(cmd + params)
    assert_cmd(expected_result, result)
  end

  it "Creates host in case the image is provided from the hostgroup and hostgroup is nested" do
      params = ['--name=test',
                '--provision-method=image',
                '--image-id=8' ,
                '--managed=true',
                '--hostgroup-id=1',
                '--organization-id=1',
                '--location-id=1'
      ]

      # nested hostgroup will return nil in compute_resource_id
      api_expects(:hostgroups, :show).with_params(
        {}
      ).returns({'compute_resource_name' => "cr", 'compute_resource_id' => nil})

      api_expects(:compute_resources, :index).with_params(
        {:search => "name = \"cr\""}
      ).returns(results: {'results' => [{'id' => 33, 'name' => "cr"}]})

      api_expects(:images, :show).with_params(
        {"compute_resource_id" => 33, "id" => 8}
      ).returns(results: {'uuid' => '111111'})

      api_expects(:hosts, :create).with_params(
        {"location_id" => 1, "organization_id" => 1, "host" => {"name" => "test", "location_id" => 1, "organization_id" => 1, "hostgroup_id" => 1, "image_id" => 8, "provision_method" => "image", "managed" => true, "compute_attributes" => {"volumes_attributes" => {}, "image_id" => nil}, "build" => true, "enabled" => true, "overwrite" => true, "interfaces_attributes" => []}}
      ).returns(results: {'uuid' => '111111'})


      expected_result = success_result("Host created.\n")
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
  end

  it 'should create a host with an owner' do
    params = ['--owner-id=1']

    api_expects(:hosts, :create, 'Create a host with an owner').with_params(
      'location_id' => 1, 'organization_id' => 1, 'host' => {
        'owner_id' => '1', 'name' => 'test'
      }
    ).returns(results: { 'owner_id' => '1', 'name' => 'test' })

    expected_result = success_result("Host created.\n")

    result = run_cmd(cmd + minimal_params_without_hostgroup + params)

    assert_cmd(expected_result, result)
  end

  it 'should create a host and set owner-type' do
    params = ['--owner=admin']

    api_expects_search(:users, {login: 'admin'}).returns(index_response([{ 'id' => 1 }]))

    api_expects(:hosts, :create, 'Create a host with an owner').with_params(
      'location_id' => 1, 'organization_id' => 1, 'host' => {
        'owner_id' => 1, 'name' => 'test'
      }
    ).returns(results: { 'owner' => 'admin', 'name' => 'test' })

    expected_result = success_result("Host created.\n")

    result = run_cmd(cmd + minimal_params_without_hostgroup + params)

    assert_cmd(expected_result, result)
  end

  it 'should create a host with default owner-type User' do

    api_expects(:hosts, :create, 'Create a host with an owner').with_params(
      'location_id' => 1, 'organization_id' => 1, 'host' => {
         'name' => 'test'
      }
    ).returns(results: { 'owner_type' => 'User', 'name' => 'test' })

    expected_result = success_result("Host created.\n")

    result = run_cmd(cmd + minimal_params_without_hostgroup)

    assert_cmd(expected_result, result)
  end
end

describe 'host update' do
  let(:cmd) { %w[host update] }
  let(:minimal_params) { ['--location-id=1', '--organization-id=1', '--id=1'] }
  let(:updated_host) do
    {
      'id' => '1',
      'organization_id' => '5',
      'location_id' => '5',
      'compute_attributes' => {},
      'puppetclass_ids' => [],
      'owner_id' => '1',
      'owner_name' => 'adminGroup',
      'owner_type' => 'Usergroup'
    }
  end

  it 'updates with passed options only' do
    params = ['--new-name=new-name']
    expected_result = success_result("Host updated.\n")

    api_expects(:hosts, :update, 'Update host name only').with_params(
      'id' => '1', 'organization_id' => 1, 'location_id' => 1,
      'host' => { 'name' => 'new-name' }
    ).returns(
      {
        'id' => '1',
        'name' => 'new-name',
        'organization_id' => '1',
        'location_id' => '1'
      }
    )

    result = run_cmd(cmd + minimal_params + params)
    assert_cmd(expected_result, result)
  end

  it 'ensures helper methods are invoked' do
    params = ['--image-id=1']
    expected_result = success_result("Host updated.\n")

    api_expects(:hosts, :show, 'Host').with_params(
      'id' => '1'
    ).returns('compute_resource_id' => '1')

    api_expects(:images, :show, 'Image').with_params(
      'id' => 1, 'compute_resource_id' => '1'
    ).returns('uuid' => '2')

    api_expects(:hosts, :update, 'Update host with image params').returns({})

    result = run_cmd(cmd + minimal_params + params)
    assert_cmd(expected_result, result)
  end

  it 'updates nothing without host related parameters' do
    api_expects(:hosts, :update, 'Update host with no host params').returns({})

    expected_result = success_result("Nothing to update.\n")

    result = run_cmd(cmd + minimal_params)
    assert_cmd(expected_result, result)
  end

  it 'updates organization with resolving name to id' do
    params = ['--new-organization', 'Org5']

    api_expects_search(:organizations, name: 'Org5').returns(
      index_response([{ 'id' => '5' }])
    )
    api_expects(:hosts, :update, 'Update host with new org').with_params(
      'id' => '1', 'location_id' => 1, 'organization_id' => 1, 'host' => {
        'organization_id' => '5' }
    ) do |par|
      par['id'] == '1' && par['host']['organization_id'] == '5'
    end.returns(updated_host)

    expected_result = success_result("Host updated.\n")

    result = run_cmd(cmd + minimal_params + params)

    assert_cmd(expected_result, result)
  end

  it 'updates location with resolving name to id' do
    params = ['--new-location', 'Loc5']

    api_expects_search(:locations, name: 'Loc5').returns(
      index_response([{ 'id' => '5' }])
    )
    api_expects(:hosts, :update, 'Update host with new loc').with_params(
      'id' => '1', 'location_id' => 1, 'organization_id' => 1, 'host' => {
        'location_id' => '5' }
    ) do |par|
      par['id'] == '1' && par['host']['location_id'] == '5'
    end.returns(updated_host)

    expected_result = success_result("Host updated.\n")

    result = run_cmd(cmd + minimal_params + params)

    assert_cmd(expected_result, result)
  end

  it 'should update the host owner' do
    params = ['--owner-type=Usergroup', '--owner=adminGroup']

    api_expects_search(:usergroups, name: 'adminGroup').returns(
        index_response([{ 'id' => '1' }])
    )
    api_expects(:hosts, :update, 'Update host with new owner').with_params(
        'id' => '1', 'location_id' => 1, 'organization_id' => 1, 'host' => {
          'owner_id' => '1' }
    ) do |par|
      par['id'] == '1' && par['host']['owner_id'] == '1'
    end.returns(updated_host)

    expected_result = success_result("Host updated.\n")

    result = run_cmd(cmd + minimal_params + params)

    assert_cmd(expected_result, result)
  end

  it 'should update the host owner with id' do
    params = ['--owner-id=1']

    api_expects(:hosts, :update, 'Update host with new owner').with_params(
      'id' => '1', 'location_id' => 1, 'organization_id' => 1, 'host' => {
        'owner_id' => '1'
      }
    ) do |par|
      par['id'] == '1' && par['host']['owner_id'] == '1'
    end.returns(updated_host)

    expected_result = success_result("Host updated.\n")

    result = run_cmd(cmd + minimal_params + params)

    assert_cmd(expected_result, result)
  end
end

describe 'host config reports' do
  let(:report15) do
    {
      "id" => 15,
        "host_id" => 1,
        "host_name" => "host.example.com",
        "reported_at" => "2017-11-13 03:04:53 UTC",
    }
  end

  it 'filters reports by --id' do
    api_expects(:config_reports, :index, 'Filter the reports') do |params|
      params['search'] == 'host_id=1'
    end.returns(index_response([report15]))

    result = run_cmd(['host', 'config-reports', '--id=1'])
    _(result.exit_code).must_equal HammerCLI::EX_OK
  end

  it 'filters reports by --name' do
    api_expects(:config_reports, :index, 'Filter the reports') do |params|
      params['search'] == 'host="host.example.com"'
    end.returns(index_response([report15]))

    result = run_cmd(['host', 'config-reports', '--name=host.example.com'])
    _(result.exit_code).must_equal HammerCLI::EX_OK
  end

  it 'prints error or missing --id and --name' do
    expected_result = CommandExpectation.new
    expected_result.expected_err = [
      'Error: At least one of options --name, --id is required.',
      '',
      "See: 'hammer host config-reports --help'.",
      ''
    ].join("\n")
    expected_result.expected_exit_code = HammerCLI::EX_USAGE

    api_expects_no_call

    result = run_cmd(['host', 'config-reports'])
    assert_cmd(expected_result, result)
  end

  it 'filters reports by --name together with search' do
    api_expects(:config_reports, :index, 'Filter the reports') do |params|
      params['search'] == 'reported > "2 hour ago" and host="host.example.com"'
    end.returns(index_response([report15]))

    result = run_cmd(['host', 'config-reports', '--name=host.example.com', '--search=reported > "2 hour ago"'])
    _(result.exit_code).must_equal HammerCLI::EX_OK
  end
end
describe 'disassociate host from vm' do
  let(:cmd) { ["host", "disassociate"] }

  it 'successful disassociate host' do
    params = ['--id=1']
    expected_result = success_result("The host has been disassociated from VM.\n")
    api_expects(:hosts, :disassociate, 'disassociate hosts') do |params|
      params['id'] == "1"
    end.returns({})

    result = run_cmd(cmd + params)
    assert_cmd(expected_result, result)
  end

  it 'prints error on missing host id' do
    expected_result = CommandExpectation.new
    expected_result.expected_err = [
      "Failed to disassociated host from VM:",
      "  Missing arguments for '--id'.",
      ''].join("\n")
    expected_result.expected_exit_code = HammerCLI::EX_USAGE

    result = run_cmd(cmd)
    assert_cmd(expected_result, result)
  end
end



describe 'list' do
  before do
    @cmd = %w[host list]
  end

  it 'should run list command with defaults' do
    providers = { 'foreman' => HammerCLIForeman::Defaults.new(api_connection({}, '2.1')) }
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
    api_expects(:hosts, :index, 'List hosts').returns(index_response([{ 'id' => '42' }]))

    result = run_cmd(@cmd, { use_defaults: true, defaults: defaults })
    _(result.exit_code).must_equal HammerCLI::EX_OK
  end
end
