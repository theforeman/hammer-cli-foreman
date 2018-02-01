require File.join(File.dirname(__FILE__), 'test_helper')


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
end

describe 'host reports' do
  let(:report15) do
    {
        "id" => 15,
        "host_id" => 1,
        "host_name" => "host.example.com",
        "reported_at" => "2017-11-13 03:04:53 UTC",
    }
  end

  it 'filters reports by --id' do
    api_expects(:reports, :index, 'Filter the reports') do |params|
      params['search'] == 'host_id=1'
    end.returns(index_response([report15]))

    result = run_cmd(['host', 'reports', '--id=1'])
    result.exit_code.must_equal HammerCLI::EX_OK
  end

  it 'filters reports by --name' do
    api_expects(:reports, :index, 'Filter the reports') do |params|
      params['search'] == 'host="host.example.com"'
    end.returns(index_response([report15]))

    result = run_cmd(['host', 'reports', '--name=host.example.com'])
    result.exit_code.must_equal HammerCLI::EX_OK
  end

  it 'prints error or missing --id and --name' do
      expected_result = CommandExpectation.new
      expected_result.expected_err =
          ['Error: At least one of options --name, --id is required.', '',
              "See: 'hammer host reports --help'.", ''].join("\n")
      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      api_expects_no_call

      result = run_cmd(['host', 'reports'])
      assert_cmd(expected_result, result)
  end

  it 'filters reports by --name together with search' do
    api_expects(:reports, :index, 'Filter the reports') do |params|
      params['search'] == 'reported > "2 hour ago" and host="host.example.com"'
    end.returns(index_response([report15]))

    result = run_cmd(['host', 'reports', '--name=host.example.com', %Q(--search=reported > "2 hour ago")])
    result.exit_code.must_equal HammerCLI::EX_OK
  end
end
